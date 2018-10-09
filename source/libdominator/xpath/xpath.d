module libdominator.xpath.xpath;

import libdominator.xpath.predicate;
import libdominator.dom;

version(unittest)
{
	import std.stdio;

	LocationPath __xpath_unittest__;
}

unittest
{
	__xpath_unittest__.steps ~= LocationStep( Axis.child , new Element("tag") );
	__xpath_unittest__.steps ~= LocationStep( Axis.child , new Element("sub") );
	__xpath_unittest__.steps ~= LocationStep( Axis.following , new Element("p") );
	__xpath_unittest__.steps ~= LocationStep( Axis.self ,
		(new Element("p"))
			.setAttribute( Attribute("id","testid") )
			.setAttribute( Attribute("class","testclass") )
	);

}

class XPathException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

enum Axis
{
	ancestor = "ancestor",
	ancestor_or_self = "ancestor-or-self",
	attribute = "attribute",
	child = "child",
	descendant = "descendant",
	descendant_or_self = "descendant-or-self",
	following = "following",
	following_sibling = "following-sibling",
	namespace = "namespace",
	parent = "parent",
	preceding = "preceding",
	preceding_sibling = "preceding-sibling",
	self = "self"
}

string abbreviate(Axis axis)
{
	switch(axis)
	{
		case Axis.self: 				return ".";
		case Axis.child: 				return "";
		case Axis.attribute: 			return "@";
		case Axis.descendant_or_self:	return "//";
		case Axis.parent: 				return "..";

		default: break;
	}
	return axis ~ "::";
}

enum PrincipalNodeType
{
	attribute,
	namespace,
	element
}



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
	Node test_node;
	Predicate[] predicates;

	this(string axis , Node test_node)
	{
		this.axis = axis.axis();
		this.test_node = test_node;
	}

	/*
	* predicates[]
	*/

	/**
	* TODO: implement attribute-axis and namespace-axis node tests
	*/
	bool test( Node context_node  , out Node[] result )
	{
		import std.uni : icmp;

		bool nodecmp(Node context , Node test)
		{
			if(0 == icmp( context.nodeName , test.nodeName ))
			{
				if( test.hasAttributes )
				{
					if( ! context.hasAttributes) return false;

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
				else
				{
					return true;
				}
			}

			return false;
		}

		if( cast(Element)context_node && cast(Element)test_node )
		{
			final switch(axis)
			{
				case Axis.self:
					if(nodecmp( context_node , test_node ))
					{
						result ~= context_node;
					}
					break;

				case Axis.child:
					foreach(child ; context_node.childNodes())
					{
						if(nodecmp( child , test_node ))
						{
							result ~= child;
						}
					}
					break;

				case Axis.ancestor_or_self:
					if(nodecmp( context_node , test_node ))
					{
						result ~= context_node;
					}
					goto case Axis.ancestor;

				case Axis.ancestor:
					foreach( ancestor ; context_node.getAncestors() )
					{
						if(nodecmp( ancestor , test_node ))
						{
							result ~= ancestor;
						}
					}
					break;

				case Axis.descendant_or_self:
					if(nodecmp( context_node , test_node ))
					{
						result ~= context_node;
					}
					goto case Axis.descendant;

				case Axis.descendant:
					foreach( descendant ; context_node.getDescendants() )
					{
						if(nodecmp( descendant , test_node ))
						{
							result ~= descendant;
						}
					}
					break;


				case Axis.following_sibling:
					bool isFollowing = false;
					foreach( sibling ; context_node.getSiblings() )
					{
						if(isFollowing && nodecmp( sibling , test_node ) )
						{
							result ~= sibling;
						}
						else if( sibling is context_node )
						{
							isFollowing = true;
						}
					}
					break;

				case Axis.preceding_sibling:
					foreach( sibling ; context_node.getSiblings() )
					{
						if( sibling is context_node )
						{
							break;
						}
						else if(nodecmp( sibling , test_node ) )
						{
							result ~= sibling;
						}
					}
					break;

				case Axis.parent:
					if(context_node.hasParent && nodecmp( context_node.parentNode , test_node ))
					{
						result ~= context_node.parentNode;
					}
					break;

				/**
				* the preceding axis contains all nodes in the same document as the context node
				* that are before the context node in document order,
				* excluding any ancestors and excluding attribute nodes and namespace nodes
				*/
				case Axis.preceding:
					if(context_node.hasParent)
					{
						foreach( parent_sibling ; context_node.parentNode.getSiblings() )
						{
							if( parent_sibling is context_node.parentNode )
							{
								break;
							}
							foreach( preceding ; parent_sibling.getDescendants() )
							{
								if( nodecmp( preceding , test_node ) )
								{
									result ~= preceding;
								}
							}
						}
					}
					break;

				case Axis.following:
					bool isFollowing = false;
					foreach( parent_sibling ; context_node.parentNode.getSiblings() )
					{
						if( isFollowing )
						{
							foreach( following ; parent_sibling.getDescendants() )
							{
								if(nodecmp( following , test_node ))
								{
									result ~= following;
								}
							}
						}
						else if( parent_sibling is context_node.parentNode )
						{
							isFollowing = true;
						}
					}
					break;

				//TODO
				case Axis.attribute:
				case Axis.namespace:
					break;
			}
			return result.length > 0;
		}

		return false;
	}

}

Axis axis(string axis)
{
	switch(axis)
	{
			case Axis.ancestor:
				return Axis.ancestor;

			case Axis.ancestor_or_self:
				return Axis.ancestor_or_self;

			case Axis.attribute:
				return Axis.attribute;

			case Axis.child:
				return Axis.child;

			case Axis.descendant:
				return Axis.descendant;

			case Axis.descendant_or_self:
				return Axis.descendant_or_self;

			case Axis.following:
				return Axis.following;

			case Axis.following_sibling:
				return Axis.following_sibling;

			case Axis.namespace:
				return Axis.namespace;

			case Axis.parent:
				return Axis.parent;

			case Axis.preceding:
				return Axis.preceding;

			case Axis.preceding_sibling:
				return Axis.preceding_sibling;

			case Axis.self:
				return Axis.self;

			default:
				throw new XPathException("unknown axis specifier '"~axis~"'");
		}
}

struct LocationPath
{
	LocationStep[] steps;
}

/**
* evaluates a XPath-LocationPath against a Node
*/
void evaluate( LocationPath path, Node context , ref Node[] result )
{
	Node[] testResults;
	if( path.steps[0].test(context , testResults) )
	{
		if( 1 == path.steps.length )
		{
			foreach( r ; testResults )
			{
				result ~= r;
			}
		}
		else
		{
			path.steps = path.steps[1..$];
			foreach( next_context ; testResults )
			{
				evaluate(path , next_context , result);

				//prevent doubles
				if(path.steps[0].axis == Axis.preceding || path.steps[0].axis == Axis.following)
				{
					break;
				}
			}
		}
	}
}

Node[] evaluate( LocationPath path , Node context )
{
	Node[] result;
	evaluate(path,context,result);
	return result;
}

LocationPath parse_path_expression(string xpath)
{
	import std.array : split;

	LocationPath locPath;

	foreach(step ; xpath.split("/"))
	{
		if(step.length) locPath.steps ~= parse_step_expression(step);
	}

	return locPath;
}

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
			step[ pred_hook .. 1+step.indexOf("]", pred_hook ) ].parse_predicate_expression();
			pred_hook = step.indexOf("[", 1+pred_hook );
		}
		while(pred_hook != -1);

	}

	return LocationStep( axis , nodetest );
}

auto parse_predicate_expression(string pred)
{
	//supports only attribute

}

unittest
{
	writeln( "child::fasel[dings=bums][ding::dong]".parse_path_expression.expression );
}

string expression(LocationPath path)
{
	import std.algorithm : map , joiner;
	import std.conv : to;
	return path.steps.map!( step => step.expression() ).joiner("/").to!string;
}

string expression_abbreviated(LocationPath path)
{
	import std.algorithm : map , joiner;
	import std.conv : to;
	return path.steps.map!( s => s.expression_abbreviated() ).joiner("/").to!string;
}

string expression(LocationStep step)
{
	import std.algorithm : map , joiner;
	import std.conv : to;

	return step.axis
	~ "::"
	~ step.test_node.nodeName()
	~ (
		step.test_node.hasAttributes()
			? step.test_node.getAttributes().map!(a => "[attribute::"~ a.name()~`="`~a.value()~`"]` ).joiner().to!string
			: ""
	)
	;
}
unittest
{
	writeln( "Full XPath Expression: " , __xpath_unittest__.expression() );
}

string expression_abbreviated(LocationStep step)
{
	import std.algorithm : map , joiner;
	import std.conv : to;

	return
	step.axis.abbreviate()
	~ step.test_node.nodeName()
	~ (
		step.test_node.hasAttributes()
			? step.test_node.getAttributes().map!(a => "["~Axis.attribute.abbreviate()~ a.name()~`="`~a.value()~`"]` ).joiner().to!string
			: ""
	)
	;
}
unittest
{
	writeln( "Abbreviated XPath Expression: " , __xpath_unittest__.expression_abbreviated() );
}

unittest
{
	string firefox_generated_xpath = "/html/body/div[1]/div[3]/div/div[2]/div/div/div[2]/div/div[2]/div[4]/div/div[2]/ol[1]/li[1]/div[1]/div[2]/div[1]/small/a";
	firefox_generated_xpath.writeln;
	writeln( firefox_generated_xpath.parse_path_expression.expression );
}