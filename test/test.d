module test.test;

import std.format;
import std.stdio;

import libdominator;

unittest
{
	Document doc =
	`<root>
		<tag_a>
			<p>preceding A</p>
			<p>preceding B</p>
		</tag_a>
		<!--
		<cment>
			<p>blafasel</p>
		</cment>
		-->
		<tag key=value fasel ding=dang\ dong >
			<sub>ding</sub>
			<sub foo=dang>dang</sub>
			<sub foo="doing">doing</sub>
			text
		</tag>
		<tag_b>
			<p id="p_ba">following A</p>
			<p id="p_bb">following B</p>
		</tag_b>
	</root>`.parse();

	//setup filter
	LocationPath xPath;
	xPath.steps ~= LocationStep( Axis.child , new Element("tag") );
	xPath.steps ~= LocationStep( Axis.child , new Element("sub") );
	xPath.steps ~= LocationStep( Axis.following , new Element("p") );

	Nodeset hits = doc.documentElement.evaluate(xPath);
	assert( hits.length == 2 , format!"unexpected %d"(hits.length));

	Node p_ba = hits[0];

	assert( p_ba.getSiblings.length == 2 );

	assert( p_ba.parentNode.nodeName == "tag_b" );
	assert( p_ba.hasParent );
	assert( p_ba.parentNode.getSiblings.length == 4 );

	assert( p_ba.hasChildNodes );
	Element p_ba_element = cast(Element)p_ba;
	assert( p_ba_element );

	Element firstChild = new Element("a");
	firstChild.setAttributeNode( new Attr("href","#first") );

	Element lastChild = new Element("a");
	lastChild.setAttribute("href","#last");

	p_ba_element.insertBefore( firstChild , p_ba_element.firstChild );
	p_ba_element.appendChild( lastChild );

	Element child = cast(Element)p_ba_element.firstChild;
	assert(child.getAttribute("href") == "#first");

	child = cast(Element)p_ba_element.lastChild;
	assert( child && child.getAttribute("href") == "#last" );
}

unittest
{
	import std.file : readText;
	import std.path : dirName;
	import std.range;

	Node doc = readText( dirName(__FILE_FULL_PATH__)~"/dummy.html" ).parse();

	auto test_node = new Element("li");
	test_node.setAttribute("id" , "li-1-o2-1") ;

	LocationPath xPath;
	xPath.steps ~= LocationStep( Axis.descendant_or_self , test_node ); /* //li[@id="li-1-o2-1"]/ */

	auto hits = doc.evaluate(xPath);
	assert( hits.length == 1 );
	assert(hits.front().firstChild().textContent() == "li-1-ol-2 Inner");
}
