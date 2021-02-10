module libdominator.xpath.locationpath.step.filter;

static import std.format;

import AxisFilter = libdominator.xpath.locationpath.axis.filter;
import libdominator.dom.node;
import libdominator.dom.nodetree.nodelist;
import libdominator.xpath.locationpath.step.step;
import libdominator.xpath.nodeset;
import libdominator.xpath.errors;

/**
* TODO: implement attribute-axis and namespace-axis node tests
* TODO: implement Predicate
*/
size_t filter(NodeList context_nodes, LocationStep step, out Nodeset output )
{

	Nodeset axisHits;
	if( 0 == AxisFilter.filter(context_nodes, step.axis, axisHits)) {
		return 0;
	}

	foreach(Node axisNode ; axisHits) {
		if( test(axisNode, step.nodeTest) ) {
			output ~= axisNode;
		}
	}
	return output.length;
}

private bool test(Node context , Node test) {

	if( context.nodeType() != test.nodeType() ) {
		return false;
	}

	switch(test.nodeType()) {

		case Node.ELEMENT_NODE:
			return testElement(cast(Element)context, cast(Element)test);

		case Node.ATTRIBUTE_NODE:
			return testAttribute(cast(Attr)context, cast(Attr)test);

		default: throw new XPathException(std.format.format!"dont know how to handle nodeType %s"(test.nodeType()));
	}
}

private bool testElement(Element context , Element test) {

	if(
		test.nodeName() != "*"
		&& context.nodeName() != test.nodeName()
	) {
		return false;
	}

	if( ! test.hasAttributes() ) {
		return true;
	}

	foreach( test_attr ; test.attributes.values )
	{
		if( ! context.hasAttribute(test_attr.name())) {
			return false;
		}

		if( ! testAttribute(context.getAttributeNode(test_attr.name()), test_attr)) {
			return false;
		}
	}

	return true;
}

private bool testAttribute(Attr context, Attr test) {
	if(
		test.name() != "*"
		&& test.name() != context.name()
	) {
		return false;
	}

	if(
		test.value
		&& test.value != context.value
	) {
		return false;
	}

	return true;
}