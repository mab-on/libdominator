module test.dom.node.element;

import libdominator.dom;

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

/// element.firstElementChild
unittest {
    import libdominator.dom.parser;
    import std.format : format;

    auto doc = `<root>
      first-Child
      <element>
        first-ElementChild
      </element>
      third-Child
      <element>
        second-ElementChild
      </element>
    </root>`.parse();

    assert( doc.documentElement.firstChild.textContent == "first-Child" , format!("got unexpected '%s'")(doc.firstChild) );
    assert( doc.documentElement.firstElementChild.textContent == "first-ElementChild" );
  }

/// element.empty_element
unittest
{
  Element elem = new Element("br");
  assert( elem.empty_element == false );
  elem.empty_element = true;
  assert( elem.empty_element == true );
}
