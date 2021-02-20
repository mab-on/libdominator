module libdominator.dom.node.node;

import libdominator.dom.node.document;
import libdominator.dom.node.element;
import libdominator.dom.nodetree.nodelist;
import libdominator.types : DOMString;

class Node
{
	static immutable ushort
		ELEMENT_NODE = 1,
		ATTRIBUTE_NODE = 2,
		TEXT_NODE = 3,
		CDATA_SECTION_NODE = 4,
		PROCESSING_INSTRUCTION_NODE = 7,
		COMMENT_NODE = 8,
		DOCUMENT_NODE = 9,
		DOCUMENT_TYPE_NODE = 10,
		DOCUMENT_FRAGMENT_NODE = 11;

	protected Node parent;
	protected NodeList childnodes;

	abstract public ushort nodeType(); //https://dom.spec.whatwg.org/#dom-node-nodetype
	abstract public string nodeName(); //https://dom.spec.whatwg.org/#dom-node-nodename

	//TODO readonly attribute USVString baseURI;

	final public bool isConnected() {
		return this.ownerDocument !is null;
	}
	public Document ownerDocument; //https://dom.spec.whatwg.org/#dom-node-ownerdocument

	//TODO Node getRootNode(optional GetRootNodeOptions options);

	final public Node parentNode() {
		//https://dom.spec.whatwg.org/#dom-node-parentnode
		return this.parent;
	}

	final public Element parentElement() {
		//https://dom.spec.whatwg.org/#ref-for-dom-node-parentelement
		if (this.parentNode() is null) {
			return null;
		}

		if ( typeid(this.parentNode()) == typeid(Element) ) {
			return cast(Element)this.parentNode();
		}

		return null;
	}

	public bool hasChildNodes() {
		//https://dom.spec.whatwg.org/#dom-node-haschildnodes
		return this.childnodes.length ? true : false;
	}

	public NodeList childNodes() {
		//https://dom.spec.whatwg.org/#dom-node-childnodes
		return this.childnodes;
	}

	public Node firstChild() {
		//https://dom.spec.whatwg.org/#dom-node-firstchild
		return this.childnodes.length ? this.childnodes[0] : null;
	}

	public Node lastChild() {
		//https://dom.spec.whatwg.org/#dom-node-lastchild
		return this.childnodes.length ? this.childnodes[$-1] : null;
	}

	public Node previousSibling() {
		//https://dom.spec.whatwg.org/#dom-node-previoussibling
		if( this.parentNode() is null ) {
			return null;
		}

		auto siblings = this.parentNode().childNodes();
		foreach( i, node ; siblings ) {
			if( this == node ) {
				return i > 0
					? siblings[i-1]
					: null;
			}
		}

		return null;
	}

	public Node nextSibling() {
		//https://dom.spec.whatwg.org/#dom-node-nextsibling
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

	abstract @property public string nodeValue(); //https://dom.spec.whatwg.org/#dom-node-nodevalue
	abstract @property public string nodeValue(string value); //https://dom.spec.whatwg.org/#dom-node-nodevalue

	// TODO public void normalize(); //https://dom.spec.whatwg.org/#dom-node-normalize

	abstract public string textContent(); //https://dom.spec.whatwg.org/#dom-node-textcontent

	// TODO public Node cloneNode(boolean deep=false); // https://dom.spec.whatwg.org/#dom-node-clonenode
	// TODO boolean isEqualNode(Node? otherNode); //https://dom.spec.whatwg.org/#dom-node-isequalnode
	// TODO boolean isSameNode(Node? otherNode); //https://dom.spec.whatwg.org/#dom-node-issamenode
	// TODO unsigned short compareDocumentPosition(Node other); //https://dom.spec.whatwg.org/#dom-node-comparedocumentposition
	// TODO boolean contains(Node? other); //https://dom.spec.whatwg.org/#dom-node-contains

	//https://dom.spec.whatwg.org/#dom-node-lookupprefix
	// https://www.w3.org/TR/DOM-Level-3-Core/namespaces-algorithms.html#lookupNamespacePrefixAlgo
	abstract DOMString lookupPrefix(DOMString namespace);

	//https://dom.spec.whatwg.org/#dom-node-lookupnamespaceuri
	abstract DOMString lookupNamespaceURI(DOMString prefix); 

	//https://dom.spec.whatwg.org/#dom-node-isdefaultnamespace
	abstract bool isDefaultNamespace(DOMString namespace);


	public Node insertBefore(Node insert , Node refChild) {
		//https://dom.spec.whatwg.org/#dom-node-insertbefore
		import std.algorithm.searching : countUntil;
		import std.array : insertInPlace;

		auto i = this.childnodes.countUntil!(child => child is refChild);
		if( i != -1 )
		{
			this.childnodes.insertInPlace( i , insert );
		}
		return insert;
	}

	public Node appendChild(Node child) {
		//https://dom.spec.whatwg.org/#dom-node-appendchild
		import std.algorithm : remove;
		if( child.parentNode !is null)
		{
		  child.parentNode.removeChild(child);
		}
		this.childnodes ~= child;
		child.setParent(this);
		return child;
	}

	// TODO //public Node replaceChild(Node node, Node child); //https://dom.spec.whatwg.org/#dom-node-replacechild

	public Node removeChild(Node child) {
		//https://dom.spec.whatwg.org/#dom-node-removechild
		import std.algorithm : remove;
		foreach( i , candidate ; this.childnodes ) {
			if( child is candidate ) {
				this.childnodes = this.childnodes.remove(i);
				return child;
			}
		}
		return null;
	}

 	// --------------------- Interface Spec END  ---------------------


	public void setParent(Node parent) {
		this.parent = parent;
	}

	public bool hasParent() {
		return (this.parent !is null);
	}


  abstract override public string toString();

  private void collectAncestors(Node node , ref NodeList nodes) {
    if(node.hasParent()) {
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

  private void collectDescendants(Node node ,ref NodeList nodes) {
    foreach(Node childNode ; node.childNodes()) {
      nodes ~= childNode;
      collectDescendants(childNode , nodes);
    }
  }

  public NodeList getDescendants() {
    NodeList nodes;
    collectDescendants(this , nodes);
    return nodes;
  }

  /**
	* Get Siblings of the current Node, including the current Node
	* Out of Spec
	*/
	public NodeList getSiblings()
	{
		if(this.hasParent())
		{
			return this.parentNode().childNodes();
		}
		return [this];
	}

}