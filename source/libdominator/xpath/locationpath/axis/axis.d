module libdominator.xpath.locationpath.axis.axis;

import libdominator.xpath.errors;

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


/**
* Every axis has a principal node type.
* If an axis can contain elements, then the principal node type is element; otherwise,
* it is the type of the nodes that the axis can contain. Thus,
*
* - For the attribute axis, the principal node type is attribute.
* - For the namespace axis, the principal node type is namespace.
* - For other axes, the principal node type is element.
*/
enum PrincipalNodeType
{
	attribute,
	namespace,
	element
}
