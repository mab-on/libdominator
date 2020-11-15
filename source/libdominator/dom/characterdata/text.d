module libdominator.dom.characterdata.text;

import libdominator.dom.node.attribute;
import libdominator.dom.characterdata.characterdata;
import libdominator.dom.node.node;

class Text : CharacterData
{
  this(string value="")
  {
    super("#text" , value);
  }

  override public ushort nodeType()
  { return Node.TEXT_NODE; }

  override public string textContent()
  { return this.nodeValue(); }

}
