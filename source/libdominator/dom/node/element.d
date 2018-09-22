module libdominator.dom.node.element;

import std.typecons : Nullable;

import libdominator.dom.node.attribute;
import libdominator.dom.node.node;

class Element : Node
{
	private string _localName;
	private string _prefix;

  private Node[] children;

  private Attribute[] attributes;

 this(string tag) {
    import std.algorithm.searching : findSplit;
		if(auto result = tag.findSplit(":"))
		{
			this._prefix = result[0];
			this._localName = result[2];
		}
		else
		{
			this._prefix = "";
			this._localName = tag;
		}
  }

  override public ushort nodeType()
  { return 1; }

  override public string nodeName() {
  	return this._prefix.length ? this._prefix ~ ":" ~ this._localName : this._localName;
  }



  override public bool hasChildNodes() {
    return this.children.length ? true : false;
  }

  override public Node[] childNodes() {
    Node[] nodes;
    foreach(Node pNode ; this.children) {
      if(pNode !is  null) { nodes ~= pNode; }
    }
    return nodes;
  }

  override public Node firstChild()
  {
  	return this.children.length ? this.children[0] : null;
  }

  override public Node lastChild()
  {
  	return this.children.length ? this.children[$-1] : null;
  }

  override public string textContent()
  {
    import std.algorithm : map , filter;
    import std.array : join , array;
    return this.childNodes().map!(n => n.textContent()).array().join(" ");
  }




  override public string outerHTML()
  {
    import std.algorithm : map;
    import std.array : join , array;
    return
    "<" ~ this.nodeName
    ~ ( this.attributes.length ? " " ~ this.attributes.map!(a => a.toString() ).array().join(' ') : "" )
    ~ ">"
    ~ this.childNodes().map!(n => n.outerHTML() ).array().join()
    ~ ( this.empty_element ? "" : "</" ~ this.nodeName ~ ">" );
  }

  override string toString()
  {
    return this.outerHTML();
  }


	public string tagName() { return this.nodeName(); }

	public string localName() { return this._localName; }

	public string prefix() { return this._prefix; }

  override @property public string nodeValue()
  { return null; }

  override @property public string nodeValue(string value)
  { return null; }


  override public Node appendChild(Node child) {
    import std.algorithm : remove;
    if( child.parentNode !is null)
    {
      child.parentNode.removeChild(child);
    }
    this.children ~= child;
    child.setParent(this);
    return child;
  }

  override public Node insertBefore(Node insert , Node refChild)
  {
  	import std.algorithm.searching : countUntil;
  	import std.array : insertInPlace;

  	auto i = this.children.countUntil!(child => child is refChild);
  	if( i != -1 )
  	{
  		this.children.insertInPlace( i , insert );
  	}
  	else
  	{

  	}

	return insert;
  }

  override public Node removeChild(Node child)
  {
    import std.algorithm : remove;
    foreach( i , candidate ; this.children )
    {
      if( child is candidate )
      {
        this.children = this.children.remove(i);
        return child;
      }
    }
    return null;
  }

  public bool hasChildren()
  {
  	import std.algorithm.searching : any;
  	if( ! this.children.length ) return false;

  	return this.children.any!(a => cast(Element)a);
  }


  private void collectDescendants(Node node ,ref Node[] nodes) {
    foreach(Node childNode ; node.childNodes()) {
      nodes ~= childNode;
      collectDescendants(childNode , nodes);
    }
  }

  override public Node[] getDescendants() {
    Node[] nodes;
    collectDescendants(this , nodes);
    return nodes;
  }

  override public Attribute[] getAttributes()
  {
    return this.attributes;
  }

  public string getAttribute(string attributeName)
  {
  	import std.algorithm.iteration : filter;

  	auto r = this.attributes.filter!(a => a.name == attributeName);
		return r.empty ? "" : r.front.value;
  }

  override public bool hasAttributes()
  {
		return this.attributes.length ? true : false;
  }

  public void addAttribute(Attribute attribute)
  {
    this.attributes ~= attribute;
  }

		/**
		* See_Also: https://developer.mozilla.org/en-US/docs/Web/API/Element/setAttribute
		*/
  public Element setAttribute(Attribute attribute)
  {
  	import std.algorithm.searching : countUntil;
		ptrdiff_t attr_index = this.attributes.countUntil!(a => a.name() == attribute.name());
		if(attr_index == -1)
		{
			this.attributes ~= attribute;
		}
    else
    {
			this.attributes[attr_index] = attribute;
    }
    return this;
  }

  public void setAttributes(Attribute[] attributes)
  {
    this.attributes = attributes;
  }

  protected bool _empty_element = false;
  /**
  * An empty element has no closing tag.
  *
  * It is an element from HTML, SVG, or MathML that cannot have any child nodes (i.e., nested elements or text nodes).
  */
  @property public bool empty_element()
  { return this._empty_element; }
  ///ditto
  @property public bool empty_element(bool value)
  { return this._empty_element = value; }
  ///
  unittest
  {
    Element elem = new Element("br");
    assert( elem.empty_element == false );
    elem.empty_element = true;
    assert( elem.empty_element == true );
  }

}
