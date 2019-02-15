module libdominator.xpath.predicate;

import libdominator.dom.node : Node;

version(unittest)
{
	import std.stdio;
}
unittest
{
	auto op = new Eq();
	writeln(op.toString());
}

auto parse_predicate_expression(in string pred, Node nodetest)
{
	import std.string : strip,isNumeric;
	string _pred = pred.strip("[] ");
	
	//if the value is a sole number, 
	//then it is to be extendet to a functioncall::NodesetFunction::Position
	if( _pred.isNumeric() )
	{
		return Predicate(PredicateExpression(
			new Position([nodetest]),
			new Number(_pred),
			new Eq()
		));	
	}
	
	return Predicate();
}

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

interface ExprToken
{
	public  string toString();
	public T value(T)(); //note, that templates will not be enforced to get implemnted!
}

interface Operator : ExprToken
{
	public bool evaluate(ExprToken a , ExprToken b);

}

class Eq : Operator
{
	public bool evaluate(ExprToken a , ExprToken b)
	{ return true; } //dummy

	override public  string toString()
	{ return "="; }
}

class OperatorAnd : Operator
{
	override public  string toString()
	{ return "and"; }

	public bool evaluate(ExprToken a , ExprToken b)
	{ return true; } //dummy
}

class OperatorOr : Operator
{
	override public  string toString()
	{ return "or"; }

	public bool evaluate(ExprToken a , ExprToken b)
	{ return true; } //dummy
}

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


class Literal : ExprToken
{
	string _value;

	this(string value) {this._value = value; }

	override string toString() { return this.value(); }
	string value() { return this.value; }
}

class Number : ExprToken
{
	double _value;

	this(double value) { this._value = value; }

	this(string value)
	{
		import std.conv : to;
		this( value.to!double );
	}

	override string toString()
	{
		import std.conv : to;
		return this.value().to!string;
	}

	 double value() { return this._value; }
}

class FunctionCall : ExprToken
{

	private string name;
	private	string[] arguments;

	this(string name , string[] arguments)
	{
		this.name = name;
		this.arguments = arguments;
	}

	override string toString()
	{
		return this.name ~ "(" ~ ")";
	}

}

class NodesetFunction : FunctionCall
{
	protected Node[] nodeset;

	this(Node[] nodeset , string name , string[] arguments)
	{
		this.nodeset = nodeset;
		super(name,arguments);
	}
}

class Position : NodesetFunction
{

	public this(Node[] nodeset)
	{
		super(nodeset , "position", []);
	}

	public size_t value() { return 1; } //dummy
}

