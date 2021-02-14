module libdominator.dom.domimplementation;

import libdominator.dom.node.documenttype;
import libdominator.dom.node.document;
import libdominator.dom.node.xmldocument;

// https://dom.spec.whatwg.org/#domimplementation
class DOMImplementation {
	//TODO DocumentType createDocumentType(DOMString qualifiedName, DOMString publicId, DOMString systemId);
	//TODO XMLDocument createDocument(DOMString? namespace, [LegacyNullToEmptyString] DOMString qualifiedName, optional DocumentType? doctype= null);
	//TODO [NewObject] Document createHTMLDocument(optional DOMString title);

	bool hasFeature() { return true; }; // useless; always returns true
} 