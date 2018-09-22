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

  html
  .appendChild(new Element("body"))
  .appendChild(new Element("p"))
  .appendChild(new Text("Blabla blah"));

  writeln( html.textContent);
}

unittest
{
  Node html = new Element("html");
  Node document_body = html.appendChild(new Element("body"));

  document_body.appendChild(new Text("Blabla blah"));

  document_body.appendChild(new Comment("This is a coment"));

  document_body
  	.appendChild(new Element("h1"))
  	.appendChild(new Text("ATENTION ATENTION!"));

  document_body
  .appendChild(new Element("p"))
  .appendChild(new Text("Blabla blub"));

  writeln( html.outerHTML );

}

