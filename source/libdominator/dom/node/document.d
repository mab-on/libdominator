module libdominator.dom.node.document;

import std.encoding;

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

	EncodingScheme encoding;

	public this() {
		this.encoding = new EncodingSchemeUtf8();
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


	// TODO [SameObject] readonly attribute DOMImplementation implementation; // https://dom.spec.whatwg.org/#domimplementation
	USVString URL = "about:blank";
	USVString documentURI = "";
	DOMString compatMode = "no-quirks";
	@property USVString characterSet() { return this.encoding.toString(); }
	@property USVString charset() { return this.characterSet; }
	@property USVString inputEncoding() { return this.characterSet; }
	DOMString contentType = "application/xml";

	DocumentType doctype;
	Element documentElement;
	
	HTMLCollection getElementsByTagName(DOMString qualifiedName) {
		return this.documentElement.getElementsByTagName(qualifiedName);
	}
	// TODO HTMLCollection getElementsByTagNameNS(DOMString? namespace, DOMString localName);
	// TODO HTMLCollection getElementsByClassName(DOMString classNames);

	// TODO [CEReactions, NewObject] Element createElement(DOMString localName, optional (DOMString or ElementCreationOptions) options = {});
	// TODO [CEReactions, NewObject] Element createElementNS(DOMString? namespace, DOMString qualifiedName, optional (DOMString or ElementCreationOptions) options= {});
  	// TODO [NewObject] DocumentFragment createDocumentFragment();
	// TODO [NewObject] Text createTextNode(DOMString data);
	// TODO [NewObject] CDATASection createCDATASection(DOMString data);
	// TODO [NewObject] Comment createComment(DOMString data);
	// TODO [NewObject] ProcessingInstruction createProcessingInstruction(DOMString target, DOMString data);
}
