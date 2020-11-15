module libdominator.dom.node.element;

import std.typecons : Nullable;

import libdominator.dom.node.attribute;
import libdominator.dom.node.node;
import libdominator.dom.node.parentnode;
import libdominator.dom.nodetree.nodelist;

class Element : Node, ParentNode {
  mixin ParentNodeMixin;
  mixin NodeImpl;

  public Attribute[] attributes;

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

  // TODO readonly attribute DOMString? namespaceURI; //https://dom.spec.whatwg.org/#dom-element-namespaceuri

  private string _prefix;
  public string prefix() {
    //https://dom.spec.whatwg.org/#dom-element-prefix
    return this._prefix;
  }

  private string _localName;
  public string localName() {
    //https://dom.spec.whatwg.org/#dom-element-localname
    return this._localName;
  }

  public string tagName() {
    import std.string : toUpper;
    //https://dom.spec.whatwg.org/#dom-element-tagname
    return this.nodeName().toUpper();
  }

  // TODO [CEReactions] attribute DOMString id;
  // TODO [CEReactions] attribute DOMString className;
  // TODO [SameObject, PutForwards=value] readonly attribute DOMTokenList classList;
  // TODO [CEReactions, Unscopable] attribute DOMString slot;

  final public bool hasAttributes() {
    // https://dom.spec.whatwg.org/#dom-element-hasattributes
    return this.attributes.length ? true : false;
  }

  final public Attribute[] getAttributes() {
    // https://dom.spec.whatwg.org/#dom-element-attributes
    return this.attributes;
  }

  // TODO sequence<DOMString> getAttributeNames(); //https://dom.spec.whatwg.org/#dom-element-getattributenames

  final public string getAttribute(string attributeName) {
    // https://dom.spec.whatwg.org/#dom-element-getattribute
    import std.algorithm.iteration : filter;

    auto r = this.attributes.filter!(a => a.name == attributeName);
    return r.empty ? "" : r.front.value;
  }

  // TODO DOMString? getAttributeNS(DOMString? namespace, DOMString localName); //https://dom.spec.whatwg.org/#dom-element-getattributens

  final public auto setAttribute(Attribute attribute) {
    // https://dom.spec.whatwg.org/#dom-element-setattribute
    import std.algorithm.searching : countUntil;
    ptrdiff_t attr_index = this.attributes.countUntil!(a => a.name() == attribute.name());
    if(attr_index == -1) {
      this.attributes ~= attribute;
    }
    else {
      this.attributes[attr_index] = attribute;
    }
    return this;
  }

  // TODO [CEReactions] undefined setAttributeNS(DOMString? namespace, DOMString qualifiedName, DOMString value);
  // TODO [CEReactions] undefined removeAttribute(DOMString qualifiedName);
  // TODO [CEReactions] undefined removeAttributeNS(DOMString? namespace, DOMString localName);
  // TODO [CEReactions] boolean toggleAttribute(DOMString qualifiedName, optional boolean force);
  // TODO boolean hasAttribute(DOMString qualifiedName);
  // TODO boolean hasAttributeNS(DOMString? namespace, DOMString localName);
  // TODO Attr? getAttributeNode(DOMString qualifiedName);
  // TODO Attr? getAttributeNodeNS(DOMString? namespace, DOMString localName);
  // TODO [CEReactions] Attr? setAttributeNode(Attr attr);
  // TODO [CEReactions] Attr? setAttributeNodeNS(Attr attr);
  // TODO [CEReactions] Attr removeAttributeNode(Attr attr);
  // TODO ShadowRoot attachShadow(ShadowRootInit init);
  // TODO readonly attribute ShadowRoot? shadowRoot;
  // TODO Element? closest(DOMString selectors);
  // TODO boolean matches(DOMString selectors);
  // TODO HTMLCollection getElementsByTagName(DOMString qualifiedName);
  // TODO HTMLCollection getElementsByTagNameNS(DOMString? namespace, DOMString localName);
  // TODO HTMLCollection getElementsByClassName(DOMString classNames);

  // --------------------- Interface Spec END  ---------------------

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

  /**
  * Gets the serialized HTML fragment describing the element including its descendants.
  *
  * See_Also:
  *   https://developer.mozilla.org/en-US/docs/Web/API/Element/outerHTML
  */
  public string outerHTML() {
    return this.toString();
  }

  override public string toString() {
    import std.algorithm : map;
    import std.array : join , array;
    return
    "<" ~ this.nodeName
    ~ ( this.attributes.length ? " " ~ this.attributes.map!(a => a.toString() ).array().join(' ') : "" )
    ~ ">"
    ~ this.childNodes().map!(n => n.toString() ).array().join()
    ~ ( this.empty_element ? "" : "</" ~ this.nodeName ~ ">" );
  }

}

private mixin template NodeImpl() {

  override public ushort nodeType() {
    return Node.ELEMENT_NODE;
  }

  override public string nodeName() {
    return this._prefix.length ? this._prefix ~ ":" ~ this._localName : this._localName;
  }

  override @property public string nodeValue() {
    return null;
  }

  override @property public string nodeValue(string value){
    return null;
  }

  override public string textContent() {
      import std.algorithm : map , filter;
      import std.array : join , array;
      return this.childNodes().map!(n => n.textContent()).array().join(" ");
  }
}
