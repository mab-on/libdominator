module libdominator.dom.node.element;

import std.algorithm.searching : findSplit;
import std.typecons;

import libdominator.dom;
import libdominator.types;
import libdominator.xpath;


class Element : Node, ParentNode {
  mixin ParentNodeMixin;
  mixin NodeImpl;

  /*
  * https://dom.spec.whatwg.org/#dom-element-attributes
  * TODO: implement NamedNodeMap
  */
  Attr[DOMString] attributes;

  DOMTokenList classList;

  this(DOMString name) {
    if(auto result = name.findSplit(":"))
    {
      this.prefix = result[0];
      this.localName = result[2];
    }
    else
    {
      this.prefix = "";
      this.localName = name;
    }

    this.classList = new DOMTokenList(this, "class");
  }

  // https://dom.spec.whatwg.org/#concept-create-element
  this(
    Document document,
    DOMString localName, 
    DOMString namespace,
    DOMString prefix=""
    // TODO DOMString is
    // TODO synchronous custom elements flag
  ) {
    if( ! prefix.length ) {
      prefix = null;
    }

    this.namespaceURI = namespace;
    this.prefix = prefix;
    this.localName = localName;
    this.ownerDocument = Document;
  }

  DOMString namespaceURI;
  DOMString prefix;
  DOMString localName;
  
  DOMString tagName() {
    import std.string : toUpper;
    //https://dom.spec.whatwg.org/#dom-element-tagname
    return this.nodeName().toUpper();
  }

  @property DOMString id(DOMString id) {
    this.setAttribute("id", id);
    return id;
  };
  @property DOMString id() {
    return this.getAttribute("id");
  };

  @property DOMString className(DOMString classname) {
    return this.classList.value(classname);
  }
  @property DOMString className() {
    return this.classList.value();
  };

  @property DOMString slot(DOMString slot) {
    this.setAttribute("slot", slot);
    return slot;
  }
  @property DOMString slot() {
    return this.getAttribute("slot");
  };

  // TODO [SameObject] readonly attribute NamedNodeMap attributes;

  // https://dom.spec.whatwg.org/#dom-element-hasattributes
  bool hasAttributes() {
    return this.attributes.length ? true : false;
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

  HTMLCollection getElementsByTagNameNS(DOMString namespace, DOMString localName) {
    return this.getElementsByTagName(
      namespace
        ? namespace~":"~localName
        : localName
    );
  }

  // https://dom.spec.whatwg.org/#dom-element-getelementsbyclassname
  // TODO: match classnames by whitespace seperated values
  HTMLCollection getElementsByClassName(DOMString classNames) {
    Element testnode = new Element("*");
    testnode.setAttribute("class", classNames);
    return new HTMLCollection( cast(Element[])this.evaluate(
        LocationPath(
          [LocationStep( Axis.descendant_or_self , testnode )]
        )
    ));    
  }

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
    auto nodeName = this.prefix.length ? this.prefix ~ ":" ~ this.localName : this.localName;
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

  // https://dom.spec.whatwg.org/#dom-node-lookupprefix
  override DOMString lookupPrefix(DOMString namespace) {
    if( ! namespace.length ) return null;

    if( this.namespaceURI == namespace ) {
      if( this.prefix.length ) return this.prefix;
    }

    foreach( attr; this.attributes ) {
      if( attr.prefix == "xmlns" && attr.value == namespace ) {
        return attr.localName;
      }
    }

    auto parent = this.parentElement();
    if( parent !is null ) {
      return parent.lookupPrefix(namespace);
    }

    return null;
  }

  // https://dom.spec.whatwg.org/#dom-node-lookupnamespaceuri
  override DOMString lookupNamespaceURI(DOMString prefix) {
    if( ! prefix.length ) {
      prefix = null;
    }

    if( this.namespaceURI.length && this.prefix == prefix ) {
      return this.namespaceURI;
    }

    foreach( attr; this.attributes ) {
      
      if( 
        attr.namespaceURI == Namespace.XMLNS 
        && attr.prefix == "xmlns"
        && attr.localName == prefix
        && attr.value.length
      ) {
        return attr.value;
      }

      if( 
        !prefix.length && !attr.prefix.length
        && attr.namespaceURI == Namespace.XMLNS
        && attr.localName == "xmlns"
        && attr.value.length
      ) {
        return attr.value;
      }

    }

    auto parent = this.parentElement();
    if( parent !is null ) {
      return parent.lookupNamespaceURI(prefix);
    }    

    return null;
  }

  //https://dom.spec.whatwg.org/#dom-node-isdefaultnamespace
  override bool isDefaultNamespace(DOMString namespace) {
    if( ! namespace.length ) {
      namespace = null;
    }
    
    auto defaultNamespace = this.lookupNamespaceURI(null);

    return defaultNamespace == namespace; 
  }
}
