module libdominator.xpath.locationpath.step.filter;

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

		if( cmp(axisNode, step.nodeTest) ) {
			output ~= axisNode;
		}
	}
	return output.length;
}

private bool cmp(Node context , Node test) {
	import std.uni : icmp;

	if( typeid(context) != typeid(test) ) {
		return false;
	}

	if(0 != icmp( context.nodeName , test.nodeName )) {
		return false;
	}

	if( typeid(test) == typeid(Element) ) {
		return cmpElement(cast(Element)context, cast(Element)test);
	}

	if( typeid(test) == typeid(Document) ) {
		throw new XPathException("Hmmm....");
		//return return cmp(context, test);
	}

	return true;
}

private bool cmpElement(Element context , Element test) {

	if( ! test.hasAttributes() ) {
		return true;
	}

	bool hitHook;
	foreach( test_attr ; test.getAttributes() )
	{
		hitHook = false;
		foreach( context_attr ; context.getAttributes() )
		{
			if
			(
				test_attr.name == context_attr.name
				&& ( test_attr.value.length ? test_attr.value == context_attr.value : true)
			)
			{
				hitHook = true;
				break;
			}
		}
		if( ! hitHook ) return false;
	}

	return true;
}
