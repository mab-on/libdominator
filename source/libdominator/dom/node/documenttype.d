module libdominator.dom.node.documenttype;

import libdominator.dom.node.node;
import libdominator.types : DOMString;

class DocumentType : Node {
	mixin NodeImpl;
	mixin SpecImpl;

	public this() {
		this.name = "";
		this.publicId = "";
		this.systemId = "";
	}

	override public string toString() {
		if ( ! name.length) return "";

		return
			"<!DOCTYPE " ~ this.nodeName() ~
			( this.publicId.length ? " "~this.publicId : "" ) ~
			( this.systemId.length ? " "~this.systemId : "" ) ~
			">";
	}
}
private mixin template SpecImpl() {
	DOMString name = "";
	DOMString publicId = "";
	DOMString systemId = "";
}

private mixin template NodeImpl() {

	override public ushort nodeType() {
		return Node.DOCUMENT_TYPE_NODE;
	}

	override public string nodeName() {
		return this.name;
	}

	override @property public string nodeValue() {
		return null;
	}

	override @property public string nodeValue(string value){
		return null;
	}

	override public string textContent() {
	  return null;
	}
}

