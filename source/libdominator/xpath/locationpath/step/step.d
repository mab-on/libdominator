module libdominator.xpath.locationpath.step.step;

import libdominator.xpath.locationpath.axis;
import libdominator.xpath.locationpath.step.predicate;
import libdominator.dom.node;

/**
*
* axis::node_test[predicate_1][predicate_N]
*
* See_Also:
* https://www.w3.org/TR/1999/REC-xpath-19991116/
*/
struct LocationStep
{
	Axis axis;
	Node nodeTest;
	Predicate[] predicates;

	this(string axis , Node nodeTest)
	{
		this.axis = axis.axis();
		this.nodeTest = nodeTest;
	}

	this(string axis , Node nodeTest , Predicate[] predicates)
	{
		this(axis,nodeTest);
		this.predicates = predicates;
	}
}
