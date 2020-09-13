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

	return
	step.axis.abbreviate()
	~ step.nodeTest.nodeName()
	~ (
		step.nodeTest.hasAttributes()
			? step.nodeTest.getAttributes().map!(a => "["~Axis.attribute.abbreviate()~ a.name()~`="`~a.value()~`"]` ).joiner().to!string
			: ""
	);
}

string expression(LocationStep step)
{
	import std.algorithm : map , joiner;
	import std.conv : to;

	return
		step.axis
		~ "::"
		~ step.nodeTest.nodeName()
		~ (
			step.nodeTest.hasAttributes()
				? step.nodeTest.getAttributes().map!(a => "[attribute::"~ a.name()~`="`~a.value()~`"]` ).joiner().to!string
				: ""
		)
		~ (
			step.predicates.length
				? step.predicates.map!( p => p.toString() ).joiner().to!string
				: ""
		);
}
