module libdominator.xpath.locationpath.step.expression;

import libdominator.xpath.locationpath.step.step;
import libdominator.xpath.locationpath.step.predicate;
import libdominator.xpath.locationpath.axis;
import libdominator.dom.node.element;

LocationStep parse_step_expression(string step)
{
	import std.algorithm.iteration : splitter;
	import std.algorithm.searching : balancedParens;
	import std.string : indexOf;
	import std.array : array;

	size_t axisnode_stop;

	axisnode_stop = step.indexOf("[");
	if(axisnode_stop == -1)
	{
		axisnode_stop = step.length;
	}

	Element nodetest;
	Axis axis = Axis.child;
	Predicate[] predicates;

	auto parts = step[0..axisnode_stop].splitter("::");
	if(parts.array.length == 1)
	{
		nodetest = new Element(parts.front());
	}
	else if(parts.array.length == 2)
	{
		axis = parts.front().axis();
		parts.popFront();
		nodetest = new Element(parts.front());
	}

	if(step.length > axisnode_stop)
	{
		import std.stdio;
		size_t pred_hook = axisnode_stop;
		do
		{
			predicates ~= step[ pred_hook .. 1+step.indexOf("]", pred_hook ) ].parse_predicate_expression();
			pred_hook = step.indexOf("[", 1+pred_hook );
		}
		while(pred_hook != -1);

	}

	return LocationStep( axis , nodetest , predicates);
}

string expression_abbreviated(LocationStep step) {
	import std.algorithm : map , joiner;
	import std.conv : to;

	string abbrev = step.axis.abbreviate() ~ step.nodeTest.nodeName();
	if( typeid(step.nodeTest) != typeid(Element) ) {
		return abbrev;
	}

	return abbrev
	~ (
		(cast(Element)step.nodeTest).hasAttributes()
			? (cast(Element)step.nodeTest).getAttributes().map!(a => "["~abbreviate(Axis.attribute)~ a.name~`="`~a.value~`"]` ).joiner().to!string
			: ""
	);
}

string expression_full(LocationStep step)
{
	import std.algorithm : map , joiner;
	import std.conv : to;

	string expr =
		step.axis
		~ "::"
		~ step.nodeTest.nodeName();

	if( typeid(step.nodeTest) == typeid(Element) && (cast(Element)step.nodeTest).hasAttributes() ) {
		expr ~= (cast(Element)step.nodeTest)
			.getAttributes()
			.map!(a => "[attribute::"~ a.name~`="`~a.value~`"]` )
			.joiner()
			.to!string;
	}

	if(step.predicates.length) {
		expr ~=	step.predicates.map!( p => p.toString() ).joiner().to!string;
	}

	return expr;
}

string expression(LocationStep step, bool abbreviate=true) {
	return abbreviate
		? step.expression_abbreviated()
		: step.expression_full();
}
