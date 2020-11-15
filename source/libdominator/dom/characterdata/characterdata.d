module libdominator.dom.characterdata.characterdata;

import libdominator.dom.errors;
import libdominator.dom.node.attribute;
import libdominator.dom.node;
import libdominator.dom.nodetree.nodelist;

abstract class CharacterData : Node
{
  protected
  	string
  		name = "",
  		value = "";

  this(string name , string value)
  {
  	this.name = name;
    this.value = value;
  }

  override @property public string nodeValue()
  { return this.value; }

  override @property public string nodeValue(string value)
  { return this.value = value; }

  override public string nodeName()
  { return this.name; }

  override public string textContent()
  { return this.nodeValue(); }

  override public string toString()
  { return this.textContent(); }

  final override public bool hasChildNodes()
  { return false; }

  final override public NodeList childNodes()
  { return []; }

  final override public Node firstChild()
  { return null; }

  final override public Node lastChild()
  { return null; }

  final override public Node removeChild(Node child)
  { throw new InvalidModificationError(); }

  final override public NodeList getDescendants() {
    return [];
  }

  final override public Node appendChild(Node child)
  { throw new InvalidModificationError(); }

  final override public Node insertBefore(Node insert , Node refChild)
  { return null; }
}
