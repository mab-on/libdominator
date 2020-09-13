module libdominator.xpath.locationpath.step.predicate.predicate;

import libdominator.xpath.locationpath.step.predicate.expression;
import libdominator.dom.node;

struct Predicate
{

	private PredicateExpression[] expr;

	this(PredicateExpression expression)
	{
		this.expr ~= expression;
	}

	this(PredicateExpression[] expressions)
	{
		this.expr = expressions;
	}

	bool evaluate(Node test_node)
	{
		return true; //todo
	}

	string toString()
	{
		import std.algorithm : map , joiner;
		import std.conv : to;
		//TODO " or "-joiner  (not only "or" are possible ;) )
		return "[" ~ this.expr.map!(p => p.toString()).joiner(" or ").to!string ~ "]";
	}
}
