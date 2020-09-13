module libdominator.xpath.locationpath.expression;

import libdominator.xpath.locationpath.locationpath;
import StepExpression = libdominator.xpath.locationpath.step.expression;

LocationPath parse_path_expression(string xpath)
{
	import std.array : split;

	LocationPath path;

	foreach(step ; xpath.split("/"))
	{
		if(step.length) path.steps ~= StepExpression.parse_step_expression(step);
	}

	return path;
}

string expression_abbreviated(LocationPath path)
{
	import std.algorithm : map , joiner;
	import std.conv : to;
	return path.steps.map!( s => StepExpression.expression_abbreviated(s) ).joiner("/").to!string;
}

string expression(LocationPath path)
{
	import std.algorithm : map , joiner;
	import std.conv : to;
	return path.steps.map!( step => StepExpression.expression(step) ).joiner("/").to!string;
}
