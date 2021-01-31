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

unittest {
  auto div = new Element("div");
  
  assert( ! div.hasAttribute("id"));
  div.id = "bla";
  assert(div.hasAttribute("id"));
  assert(div.id == "bla");

  div.id = "fasel";
  assert(div.id == "fasel");
}

unittest {
  auto div = new Element("div");
  assert(div.className == "");
  assert(div.classList.length == 0);

  div.className = "test";
  assert(div.className == "test");
  assert(div.classList.length == 1);

  div.className = "test 12  123";
  assert(div.className == "test 12  123");
  assert(div.classList.length == 3);
}

unittest {
  auto div = new Element("div");
  assert( ! div.hasAttributes());

  div.setAttribute("bla","fasel");
  assert(div.hasAttributes());

  div.removeAttribute("bla");  
  assert( ! div.hasAttributes());
}