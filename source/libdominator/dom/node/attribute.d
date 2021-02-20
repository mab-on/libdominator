module libdominator.dom.node.attribute;

import libdominator.dom.node.node;
import libdominator.dom.node.element;
import libdominator.dom.nodetree.nodelist;
import libdominator.types : DOMString;

class Attr : Node {
	mixin NodeImpl;
	mixin SpecImpl;

	char _wrapper;

	this(DOMString name, DOMString value="" , char wrapper='"' ) {
		import std.algorithm.searching : findSplit;

		if(auto result = name.findSplit(":")) {
			this.prefix = result[0];
			this.localName = result[2];
		} else {
			this.prefix = "";
			this.localName = name;
		}

		this.value = value;

		this._wrapper = wrapper;
	}

	override public string toString() {

	  	string escape(string value , char wrapper) {
	  		if(wrapper == 0x00) return value;

	  		string escaped;
	  		for(size_t i; i<value.length; i++)
	  		{
	  			if(value[i] == wrapper)
	  			{
	  				if(i == 0) { escaped = '\\'  ~ value[0..i]; }

	  				else if(value[i-1] != '\\')
	  				{
	  					if(escaped.length) { escaped ~= "\\" ~ value[i]; }
	  					else
	  						{ escaped = value[0..i] ~ '\\'  ~ value[i]; }
	  				}
	  			}
	  			else if(escaped.length) { escaped ~= value[i]; }
	  		}
	  		return wrapper ~ (escaped.length ? escaped : value) ~ wrapper;
	  	}

	  	return this.name()
	  	~ ( this.value.length
	  		? "=" ~ escape(this.value , this._wrapper)
	  		: ""
	  		);
  }

  override DOMString lookupPrefix(DOMString namespace) {
		return this.ownerElement is null
			? null
			: this.ownerElement.lookupPrefix(namespace);
	}

	override DOMString lookupNamespaceURI(DOMString prefix) {
		return this.ownerElement is null
			? null
			: this.ownerElement.lookupNamespaceURI(prefix);	
	}

	override bool isDefaultNamespace(DOMString namespace) {
		return this.ownerElement is null
			? null
			: this.ownerElement.isDefaultNamespace(namespace);	
	}
}

private mixin template NodeImpl() {

	override public ushort nodeType() {
		return Node.ATTRIBUTE_NODE;
	}

	override public string nodeName() {
		return this.name();
	}

	override @property public string nodeValue() {
		return this.value;
	}

	override @property public string nodeValue(string value) {
		return this.value = value;
	}

	override public string textContent() {
		return this.value;
	}

	override public NodeList childNodes() {
		return [];
	}
}

///https://dom.spec.whatwg.org/#attr
private mixin template SpecImpl() {

  DOMString namespaceURI;
  DOMString prefix;
  DOMString localName;
  DOMString name() {
  	return this.prefix.length
  		? this.prefix~":"~this.localName
  		: this.localName;
  }
  DOMString value;
  Element ownerElement;
  
  // https://dom.spec.whatwg.org/#dom-attr-specified
  bool specified() {
  	return true;
  }

}
