module libdominator.dom.characterdata.characterdata;
import libdominator.dom.node;
import libdominator.dom.domexception;

class CharacterData : Node
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

  override public string outerHTML()
  { return this.textContent(); }

  override public ushort nodeType()
  { return 0; }

  final override public bool hasChildNodes()
  { return false; }

  final override public Node[] childNodes()
  { return []; }

  final override public Node firstChild()
  { return null; }

  final override public Node lastChild()
  { return null; }

  final override public Node removeChild(Node child)
  { throw new InvalidModificationError(); }

  final override public Node[] getDescendants() {
    return [];
  }

  final override public Node appendChild(Node child)
  { throw new InvalidModificationError(); }

  final override public Node insertBefore(Node insert , Node refChild)
  { return null; }

  override public Attribute[] getAttributes()
  { return []; }

  override public bool hasAttributes()
  { return false; }

}
