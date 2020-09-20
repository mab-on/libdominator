module libdominator.dom.node.node;

import libdominator.dom.node.attribute;
import libdominator.dom.node.element;
import libdominator.dom.nodetree.nodelist;

class Node
{
	protected Node parent;

	public void setParent(Node parent)
  {
    this.parent = parent;
  }

	/**
  * Returns: true if the Node has a parent Node.
  */
  public bool hasParent() {
    return (this.parent !is null);
  }

	/**
  * Represents the type of the node.
  *
  * See_Also:
  *   https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeType
  *
  */
  abstract public ushort nodeType();

  /**
  * Name of the current node as a string
  *
  * See_Also:
  *   https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeName
  *   https://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1841493061
  */
   public string nodeName();

	//TODO
	//readonly attribute USVString baseURI;

	//TODO
	//readonly attribute boolean isConnected;

	//TODO
	//readonly attribute Document? ownerDocument;

	//TODO
	//Node getRootNode(optional GetRootNodeOptions options);

	/**
	* The parentNode attribute’s getter must return the context object’s parent.
	*
	* See_Also:
	*		https://dom.spec.whatwg.org/#dom-node-parentnode
	*/
  final public Node parentNode()
  {
    return this.parent;
  }

	/**
	* parentElement is the parent element of the current node. This is always a DOM Element object, or null

	* See_Also:
	*		https://dom.spec.whatwg.org/#dom-node-parentelement
	*		https://dom.spec.whatwg.org/#parent-element
	*		https://developer.mozilla.org/en-US/docs/Web/API/Node/parentElement
	*/
	public Element parentElement() {
		if (this.parentNode() is null) {
			return null;
		}

		if ( typeid(this.parentNode()) == typeid(Element) ) {
			return cast(Element)this.parentNode();
		}

		return null;
	}

  /**
  *return true if the context object has children, and false otherwise.
  *
  * See_Also:
  * 	https://dom.spec.whatwg.org/#dom-node-haschildnodes
  */
  abstract public bool hasChildNodes();

	/**
	* The childNodes attribute’s getter must return a NodeList rooted at the context object matching only children.
	*
	* See_Also:
  * 	https://dom.spec.whatwg.org/#dom-node-childnodes
	*/
  abstract public NodeList childNodes();

	/**
	*
	* See_Also:
	* https://dom.spec.whatwg.org/#dom-node-firstchild
	*/
  abstract public Node firstChild();

  /**
	*
	* See_Also:
	* https://dom.spec.whatwg.org/#dom-node-lastchild
	*/
  abstract public Node lastChild();

	/**
	* TODO
	* The previousSibling attribute’s getter must return the context object’s previous sibling or null
	*
	* Note:
	* 	An Attr node has no siblings.
	*
	* See_Also:
	*		https://dom.spec.whatwg.org/#dom-node-previoussibling
	*		https://developer.mozilla.org/en-US/docs/Web/API/Node/previousSibling
	*/
  //public Node previousSibling();

	/**
	* The nextSibling attribute’s getter must return the context object’s next sibling or null
	*
	* See_Also:
	*		https://dom.spec.whatwg.org/#dom-node-nextsibling
	*
	*/
	public Node nextSibling() {
		if( this.parentNode() is null ) {
			return null;
		}

		auto siblings = this.parentNode().childNodes();
		foreach( i, node ; siblings ) {
			if( this == node ) {
				return 1+i < siblings.length
					? siblings[1+i]
					: null;
			}
		}

		return null;
	}


  /**
  * returns or sets the value of the current node
  *
  * Is a DOMString representing the value of an object.
  * For most Node type, this returns null and any set operation is ignored.
  * For nodes of type TEXT_NODE (Text objects), COMMENT_NODE (Comment objects), the value corresponds to the text data contained in the object.
  *
  * The nodeValue attribute must return the following, depending on the context object:
	*	Attr: Context object’s value.
	*	Text, ProcessingInstruction, Comment: Context object’s data.
	*	Any other node: Null
  *
  * See_Also:
  * 	https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeValue
  *		https://dom.spec.whatwg.org/#dom-node-nodevalue
  */
  abstract @property public string nodeValue();
  ///ditto
  abstract @property public string nodeValue(string value);



  /**
  * removes a child node from the DOM. Returns removed node.
  *
  * See_Also:
  *   https://developer.mozilla.org/en-US/docs/Web/API/Node/removeChild
  */
  abstract public Node removeChild(Node child);



  private void collectAncestors(Node node , ref NodeList nodes) {
    if(node.hasParent) {
      auto parentNode = node.parentNode();
      nodes ~= parentNode;
      collectAncestors(parentNode , nodes);
    }
  }

  public NodeList getAncestors() {
    NodeList nodes;
    collectAncestors(this , nodes);
    return nodes;
  }

  abstract public NodeList getDescendants();



  /**
  * Represents the text content of a node and its descendants.
  *
  * If the node is a comment or a text node, textContent returns the text inside this node (the nodeValue).
  * For other node types, textContent returns the concatenation of the textContent property value of every child node, excluding comments. This is an empty string if the node has no children.
  * Setting this property on a node removes all of its children and replaces them with a single text node with the given value.
  *
  * The textContent attribute’s getter must return the following, switching on context object:
	*
	*	DocumentFragment, Element: The concatenation of data of all the Text node descendants of the context object, in tree order.
	*	Attr: Context object’s value.
	*	Text, ProcessingInstruction, Comment: Context object’s data.
	*	Any other node: Null
  *
  * See_Also:
  *   https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent
  *		https://dom.spec.whatwg.org/#dom-node-textcontent
  */
  abstract public string textContent();

	/**
	* TODO
	* The textContent attribute’s setter must, if the given value is null, act as if it was the empty string instead, and then do as described below, switching on context object:
	*	DocumentFragment,Element:
	*	  Let node be null.
	*	  If the given value is not the empty string, set node to a new Text node whose data is the given value and node document is context object’s node document.
	*	  Replace all with node within the context object.
	*	Attr:
	*		Set an existing attribute value with context object and new value.
	*	Text,ProcessingInstruction,Comment:
	*	  Replace data with node context object, offset 0, count context object’s length, and data the given value.
	*	Any other node:
	*		Do nothing.
	*
	* See_Also:
	*		https://dom.spec.whatwg.org/#dom-node-textcontent
	*
	*/
	//public void textContent(string value);

	/**
	* TODO
	* puts the specified node and all of its sub-tree into a "normalized" form. In a normalized sub-tree, no text nodes in the sub-tree are empty and there are no adjacent text nodes.
	*
	* See_Also:
	*		https://dom.spec.whatwg.org/#dom-node-normalize
	*		https://developer.mozilla.org/en-US/docs/Web/API/Node/normalize
	*/
	//public void normalize();

	/**
	* TODO
	*
	*
	* See_Also:
	* https://dom.spec.whatwg.org/#dom-node-clonenode
	*/
	//public Node cloneNode(boolean deep=false);

	/**
	* TODO
	*	compares the position of the current node against another node in any other document.
	*
	* See_Also:
	*	https://dom.spec.whatwg.org/#dom-node-comparedocumentposition
	*	https://developer.mozilla.org/en-US/docs/Web/API/Node/compareDocumentPosition
	*/
	//ushort compareDocumentPosition(Node other);

	/**
	*	TODO
	*	indicating whether a node is a descendant of a given node, i.e. the node itself, one of its direct children (childNodes), one of the children's direct children, and so on.
	*
	* See_Also:
	*		https://dom.spec.whatwg.org/#dom-node-contains
	*		https://developer.mozilla.org/en-US/docs/Web/API/Node/contains
	*/
	//bool contains(Node other);

	/**
	* TODO
	* returns a DOMString containing the prefix for a given namespace URI, if present, and null if not.
	* When multiple prefixes are possible, the result is implementation-dependent.
	*
	*
	* See_Also:
	*	https://dom.spec.whatwg.org/#dom-node-lookupprefix
	*	https://developer.mozilla.org/en-US/docs/Web/API/Node/lookupPrefix
	*	https://www.w3.org/TR/DOM-Level-3-Core/core.html#Node3-lookupNamespacePrefix
	*/
	//string lookupPrefix(string namespace);

	/**
	* TODO
	*	accepts a prefix and returns the namespace URI associated with it on the given node if found (and null if not). Supplying null for the prefix will return the default namespace.
	*
	* See_Also:
	*		https://dom.spec.whatwg.org/#dom-node-lookupnamespaceuri
	*		https://developer.mozilla.org/en-US/docs/Web/API/Node/lookupNamespaceURI
	*/
	//string lookupNamespaceURI(string prefix);

	/**
	* TODO
	* accepts a namespace URI as an argument and returns a Boolean with a value of true if the namespace is the default namespace on the given node or false if not.
	*
	* See_Also:
	*	https://dom.spec.whatwg.org/#dom-node-isdefaultnamespace
	*/
	//boolean isDefaultNamespace(string namespace);

	/**
	* inserts a node before the reference node as a child of a specified parent node
	*
	* See_Also:
	*	https://dom.spec.whatwg.org/#dom-node-insertbefore
	*	https://developer.mozilla.org/en-US/docs/Web/API/Node/insertBefore
	*/
	abstract public Node insertBefore(Node insert , Node refChild);

	/**
	* dds a node to the end of the list of children of a specified parent node
	*
	* See_Also:
	*	https://dom.spec.whatwg.org/#dom-node-appendchild
	*	https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild
	*
	*/
    abstract public Node appendChild(Node child);

	/**
	* TODO
	* replaces one child node of the specified node with another.
	*
	* See_Also:
	* https://dom.spec.whatwg.org/#dom-node-replacechild
	*	https://developer.mozilla.org/en-US/docs/Web/API/Node/replaceChild
	*/
	//public Node replaceChild(Node node, Node child);

  /**
  * Gets the serialized HTML fragment describing the element including its descendants.
  *
  * See_Also:
  *   https://developer.mozilla.org/en-US/docs/Web/API/Element/outerHTML
  */
  abstract public string outerHTML();

  abstract public Attribute[] getAttributes();
  abstract public bool hasAttributes();

  /**
	* Get Siblings of the current Element
	* No W3 standard
	*/
	public NodeList getSiblings()
	{
		if(this.hasParent)
		{
			return this.parentNode().childNodes();
		}
		return [this];
	}
}
