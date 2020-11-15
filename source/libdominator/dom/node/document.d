module libdominator.dom.node.Document;

import libdominator.dom.node.attribute;
import libdominator.dom.node.documenttype;
import libdominator.dom.node.node;
import libdominator.dom.node.parentnode;
import libdominator.dom.nodetree.nodelist;
import libdominator.types;

/**
* https://dom.spec.whatwg.org/#document
* https://dom.spec.whatwg.org/#nodes
*/
class Document : Node, ParentNode {
	mixin NodeImpl;
	mixin ParentNodeMixin;
	mixin SpecImpl;

	this() {
		this.doctype = new DocumentType();
	}

	override public string toString() {
	    return this.documentElement.toString();
	}
}

private mixin template NodeImpl() {

	override public ushort nodeType() {
		return Node.DOCUMENT_NODE;
	}

	override public string nodeName() {
		return "#document";
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

	override public NodeList childNodes() {
		import std.algorithm.iteration : filter;
		import std.array : array;

		return [
			this.doctype,
			this.documentElement
		].filter!(node => node !is null).array();
	}
}

private mixin template SpecImpl() {
	import libdominator.types;
	import std.encoding;

	EncodingScheme encoding = new EncodingSchemeUtf8();
	DOMString contentType = "application/xml";
	USVString URL = "about:blank";
	USVString documentURI = "";
	DOMString compatMode = "no-quirks";

	// TODO [SameObject] readonly attribute DOMImplementation implementation; // https://dom.spec.whatwg.org/#domimplementation

	public USVString characterSet() { return this.encoding.toString(); }
	public USVString charset() { return this.characterSet(); }
	public USVString inputEncoding() { return this.characterSet(); }

	DocumentType doctype;
	Element documentElement;
	// TODO HTMLCollection getElementsByTagName(DOMString qualifiedName);
	// TODO HTMLCollection getElementsByTagNameNS(DOMString? namespace, DOMString localName);
	// TODO HTMLCollection getElementsByClassName(DOMString classNames);
}
