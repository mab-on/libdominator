module libdominator.xpath.locationpath.step.predicate.expression.token;

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

	this(string name)
	{
		this.name = name;
	}

	override string toString()
	{
		return this.name ~ "(" ~ ")";
	}
}

class NodesetFunction : FunctionCall
{
	this(string name)
	{
		super(name);
	}
}

class Position : NodesetFunction
{
	public this()
	{
		super("position");
	}

	public size_t value() { return 1; } //dummy
}
