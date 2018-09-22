module libdominator.test;

import std.stdio;
import libdominator;

unittest
{
	Node doc =
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
	</root>`.parse;

	//setup filter
	LocationPath xPath;
	xPath.steps ~= LocationStep( Axis.child , new Element("tag") );
	xPath.steps ~= LocationStep( Axis.child , new Element("sub") );
	xPath.steps ~= LocationStep( Axis.following , new Element("p") );

	Node[] hits = xPath.evaluate(doc);
	Node p_ba = hits[0];

	assert( hits.length == 2 );
	assert( p_ba.getSiblings.length == 2 );

	assert( p_ba.parentNode.nodeName == "tag_b" );
	assert( p_ba.hasParent );
	assert( p_ba.parentNode.getSiblings.length == 4 );

	assert( p_ba.hasChildNodes );
	Element p_ba_element = cast(Element)p_ba;
	assert( p_ba_element );
	assert( ! p_ba_element.hasChildren );

	p_ba_element.insertBefore( (new Element("a")).setAttribute( Attribute("href","#first") ) , p_ba_element.firstChild );
	p_ba_element.appendChild( (new Element("a")).setAttribute( Attribute("href","#last") ) );

	assert( p_ba_element.hasChildren );

	Element child = cast(Element)p_ba_element.firstChild;
	assert( child && child.getAttribute("href") == "#first" );

	child = cast(Element)p_ba_element.lastChild;
	assert( child && child.getAttribute("href") == "#last" );

	writeln("------------------");
	writeln( doc.outerHTML );
	writeln("------------------");

}

unittest
{
	import std.file : readText;
	import std.path : dirName;

	Node doc = readText( dirName(__FILE_FULL_PATH__)~"/dummy.html" ).parse;

	LocationPath xPath;
	auto test_node = new Element("li");
	test_node.addAttribute( Attribute("id" , "li-1-o2-1") );
	xPath.steps ~= LocationStep( Axis.descendant_or_self , test_node );

	foreach(hit ; xPath.evaluate(doc))
	{
		writeln( hit.outerHTML );
	}

}