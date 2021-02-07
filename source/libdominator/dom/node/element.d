module libdominator.dom.node.element;

import std.algorithm.searching : findSplit;
import std.typecons;

import libdominator.dom;
import libdominator.types;
import libdominator.xpath;


class Element : Node, ParentNode {
  mixin ParentNodeMixin;
  mixin NodeImpl;

  Attr[DOMString] attributes;

  this() {}

  this(DOMString name) {
    if(auto result = name.findSplit(":"))
    {
      this._prefix = result[0];
      this._localName = result[2];
    }
    else
    {
      this._prefix = "";
      this._localName = name;
    }
  }

  private DOMString _prefix;
  DOMString prefix() {
    //https://dom.spec.whatwg.org/#dom-element-prefix
    return this._prefix;
  }

  private DOMString _localName;
  DOMString localName() {
    //https://dom.spec.whatwg.org/#dom-element-localname
    return this._localName;
  }

  DOMString tagName() {
    import std.string : toUpper;
    //https://dom.spec.whatwg.org/#dom-element-tagname
    return this.nodeName().toUpper();
  }

  // TODO
  private DOMString _namespaceURI;
  DOMString namespaceURI() {
    return this._namespaceURI;
  }

  @property DOMString id(DOMString id) {
    this.setAttribute("id", id);
    return id;
  };
  @property DOMString id() {
    return this.getAttribute("id");
  };

  @property DOMString className(DOMString _class) {
    this.setAttribute("class", _class);
    return _class;
  }
  @property DOMString className() {
    return this.getAttribute("class");
  };

  DOMTokenList classList() {
    import std.algorithm.iteration : splitter,filter;
    import std.array;
    
    auto className = this.className();
    if( ! className ) {
      return [];
    }

    return className.splitter(' ').filter!(i => i.length).array;
  }

  @property DOMString slot(DOMString slot) {
    this.setAttribute("slot", slot);
    return slot;
  }
  @property DOMString slot() {
    return this.getAttribute("slot");
  };

  // https://dom.spec.whatwg.org/#dom-element-hasattributes
  bool hasAttributes() {
    return this.attributes.length ? true : false;
  }

  // https://dom.spec.whatwg.org/#dom-element-attributes
  Attr[] getAttributes() {
    return this.attributes.values;
  }

  // https://dom.spec.whatwg.org/#dom-element-getattributenames
  DOMString[] getAttributeNames() {
    return this.attributes.keys;
  }

  // https://dom.spec.whatwg.org/#dom-element-getattribute
  DOMString getAttribute(DOMString qualifiedName) {
    if( auto attr = this.getAttributeNode(qualifiedName) ) {
      return attr.value;
    }
    return "";
  }

 //https://dom.spec.whatwg.org/#dom-element-getattributens
 DOMString getAttributeNS(DOMString namespace, DOMString localName) {
  auto attr = namespace 
      ? this.getAttributeNode(namespace~":"~localName)
      : this.getAttributeNode(localName);

  return attr is null
    ? ""
    : attr.value; 
 }

  void removeAttribute(DOMString qualifiedName){
    if( this.hasAttribute(qualifiedName) ) {
      this.attributes.remove(qualifiedName);
    }
  }

  void removeAttributeNS(DOMString namespace, DOMString localName) {
    if(namespace) {
      this.removeAttribute(namespace~":"~localName);
    } else {
      this.removeAttribute(localName);
    }
  }

  Attr removeAttributeNode(Attr attr) {
    if( ! this.hasAttribute(attr.name())) {
      throw new NotFoundError();
    }
    this.removeAttribute(attr.name());
    return attr;
  }
  
  bool toggleAttribute(DOMString qualifiedName, /* bool force */ ) {
    if( this.hasAttribute(qualifiedName) ) {
      this.removeAttribute(qualifiedName);
      return false;
    }

    this.setAttribute(qualifiedName);
    return true;
  }

  bool hasAttribute(DOMString qualifiedName) {
    return this.getAttributeNode(qualifiedName) !is null;
  }

  bool hasAttributeNS(DOMString namespace, DOMString localName) {
    return this.getAttributeNodeNS(namespace, localName) !is null;
  }
  Attr getAttributeNode(DOMString qualifiedName) {
    if( auto attr = qualifiedName in this.attributes ) {
      return (*attr);
    }
    return null;
  }
  Attr getAttributeNodeNS(DOMString namespace, DOMString localName) {
    return namespace 
      ? this.getAttributeNode(namespace~":"~localName)
      : this.getAttributeNode(localName);
  }

  // https://dom.spec.whatwg.org/#concept-element-attributes-set
  alias setAttributeNodeNS = setAttributeNode;
  Attr setAttributeNode(Attr attr) {
    // If attr’s element is neither null nor element, throw an "InUseAttributeError" DOMException.
    if( attr.ownerElement !is null ) {
      throw new InUseAttributeError();
    }

    // Let oldAttr be the result of getting an attribute given attr’s namespace, attr’s local name, and element.
    auto oldAttr = this.getAttributeNodeNS(attr.prefix, attr.localName);

    // If oldAttr is attr, return attr.
    if( oldAttr == attr ) {
      return attr;
    }

    // If oldAttr is non-null, then replace oldAttr with attr.
    // Otherwise, append attr to element.
    attr.ownerElement = this;
    if ( oldAttr !is null ) {
      oldAttr = attr;
    } else {
      this.attributes[attr.name()] = attr;
    }

    return attr;
  }

  void setAttributeNS(DOMString namespace, DOMString qualifiedName, DOMString value="") {
    return namespace 
      ? this.setAttribute(namespace~":"~localName, value)
      : this.setAttribute(localName, value);
  }
  void setAttribute(DOMString qualifiedName, DOMString value="") {
    this.setAttributeNode( new Attr(qualifiedName, value) );
  }

  // TODO ShadowRoot attachShadow(ShadowRootInit init);
  // TODO readonly attribute ShadowRoot? shadowRoot;
  // TODO Element? closest(DOMString selectors);
  // TODO boolean matches(DOMString selectors);

  HTMLCollection getElementsByTagName(DOMString qualifiedName) {
    return new HTMLCollection( cast(Element[])this.evaluate(
        LocationPath(
          [LocationStep( Axis.descendant_or_self , new Element(qualifiedName) )]
        )
    ));
  }
  // TODO HTMLCollection getElementsByTagNameNS(DOMString? namespace, DOMString localName);
  // TODO HTMLCollection getElementsByClassName(DOMString classNames);

  // --------------------- Interface Spec END  ---------------------

  protected bool _empty_element = false;
  /**
  * An empty element has no closing tag.
  *
  * It is an element from HTML, SVG, or MathML that cannot have any child nodes (i.e., nested elements or text nodes).
  */
  @property bool empty_element()
  { return this._empty_element; }
  ///ditto
  @property bool empty_element(bool value)
  { return this._empty_element = value; }

  /**
  * Gets the serialized HTML fragment describing the element including its descendants.
  *
  * See_Also:
  *   https://developer.mozilla.org/en-US/docs/Web/API/Element/outerHTML
  */
  string outerHTML() {
    return this.toString();
  }

  override string toString() {
    import std.algorithm : map;
    import std.array : join , array;
    return
    "<" ~ this.nodeName
    ~ ( this.attributes.length ? " " ~ this.attributes.values.map!(a => a.toString() ).array().join(' ') : "" )
    ~ ">"
    ~ this.childNodes().map!(n => n.toString() ).array().join()
    ~ ( this.empty_element ? "" : "</" ~ this.nodeName ~ ">" );
  }

}

private mixin template NodeImpl() {

  override ushort nodeType() {
    return Node.ELEMENT_NODE;
  }

  override string nodeName() {
    import std.uni : toUpper, sicmp;
    auto nodeName = this._prefix.length ? this._prefix ~ ":" ~ this._localName : this._localName;
    return this.isConnected() && ownerDocument.doctype !is null && 0 == sicmp(ownerDocument.doctype.nodeName() , "html")
      ? toUpper(nodeName)
      : nodeName;
  }

  override @property string nodeValue() {
    return null;
  }

  override @property string nodeValue(string value){
    return null;
  }

  override string textContent() {
      import std.algorithm : map , filter;
      import std.array : join , array;
      return this.childNodes().map!(n => n.textContent()).array().join(" ");
  }
}
