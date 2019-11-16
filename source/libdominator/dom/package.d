module libdominator.dom;

public import libdominator.dom.characterdata;
public import libdominator.dom.node;
public import libdominator.dom.domexception;

import std.uni : toLower;
import std.format : format ;
import std.conv : to ;

version(unittest)
{
	import std.stdio;
}


///
unittest
{
  Node root = new Element("root");

  root.appendChild(new Element("roots-child-bob"));

  Node grand_child = root
  .appendChild(new Element("roots-child-alice"))
  .appendChild(new Element("child-of-alice"));

  assert(grand_child.getAncestors.length == 2);
  assert(root.getDescendants().length == 3);
}

unittest
{
  Node html = new Element("html");
  auto paragraph = new Element("p");
  html
  .appendChild(new Element("body"))
  .appendChild(paragraph)
  .appendChild(new Text("Blabla blah"));

  assert( html.textContent == "Blabla blah");
  assert( paragraph.textContent == "Blabla blah");
   
}
