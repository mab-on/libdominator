module test.dom.node.attribute;

import libdominator.dom.node.attribute;

unittest
{
	assert( Attribute("key" , "value" , '"').toString == `key="value"` );
	assert( Attribute("key" , "value" , 0x00).toString == `key=value` );
	assert(
		Attribute("key" , `value with "doublequotes" and 'singlequotes'` , '"').toString
		==
		`key="value with \"doublequotes\" and 'singlequotes'"`
		);
	assert(
		Attribute("key" , `value with "doublequotes" and 'singlequotes'` , '\'').toString
		==
		`key='value with "doublequotes" and \'singlequotes\''`
		);
	assert(
		Attribute("key" , `value with \"doublequotes\" , "doublequotes" and 'singlequotes'` , '"').toString
		==
		`key="value with \"doublequotes\" , \"doublequotes\" and 'singlequotes'"`
		);
}
