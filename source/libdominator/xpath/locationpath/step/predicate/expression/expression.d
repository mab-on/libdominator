module libdominator.xpath.locationpath.step.predicate.expression.expression;

import libdominator.xpath.locationpath.step.predicate.expression.token;
import libdominator.xpath.locationpath.step.predicate.predicate;

struct PredicateExpression
{
	ExprToken a;
	Operator op;
	ExprToken b;

	this(ExprToken a, ExprToken b, Operator op)
	{
		this.a = a;
		this.op = op;
		this.b = b;
	}

	public string toString()
	{
		string ret = a.toString() ~ op.toString() ~ b.toString();
		return ret;
	}
}

auto parse_predicate_expression(in string pred)
{
	import std.string : strip,isNumeric;
	string _pred = pred.strip("[] ");

	//if the value is a sole number,
	//then it is to be extendet to a functioncall::NodesetFunction::Position
	if( _pred.isNumeric() )
	{
		return Predicate(PredicateExpression(
			new Position(),
			new Number(_pred),
			new Eq()
		));
	}

	return Predicate();
}
