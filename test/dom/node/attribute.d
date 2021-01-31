module test.dom.node.attribute;

import std.format;
import libdominator.dom.node.attribute;

unittest
{
	assert( (new Attr("key" , "value" , '"')).toString() == `key="value"`, format!"unexpected '%s'"((new Attr("key" , "value" , '"')).toString()) );
	assert( (new Attr("key" , "value" , 0x00)).toString() == `key=value` );
	assert(
		(new Attr("key" , `value with "doublequotes" and 'singlequotes'` , '"')).toString()
		==
		`key="value with \"doublequotes\" and 'singlequotes'"`
		);
	assert(
		(new Attr("key" , `value with "doublequotes" and 'singlequotes'` , '\'')).toString()
		==
		`key='value with "doublequotes" and \'singlequotes\''`
		);
	assert(
		(new Attr("key" , `value with \"doublequotes\" , "doublequotes" and 'singlequotes'` , '"')).toString()
		==
		`key="value with \"doublequotes\" , \"doublequotes\" and 'singlequotes'"`
		);
}

unittest {
	import libdominator.dom.node.node;

	auto attr = new Attr("the-key", "the-value");

	assert(Node.ATTRIBUTE_NODE == attr.nodeType());
	assert("the-key" == attr.nodeName());

	assert("the-value" == attr.nodeValue());
	attr.nodeValue("the-other-value");
	assert("the-other-value" == attr.nodeValue());

	assert(attr.ownerElement is null);
}

unittest {
	import libdominator.dom.parser;

	auto doc = `<tmp the-key="the-value"></tmp>`.parse();
	auto attr = doc.documentElement.getAttributes();
	assert(doc.documentElement == attr[0].ownerElement);
}
