module libdominator.dom.domimplementation;

import libdominator.dom;
import libdominator.types;

// https://dom.spec.whatwg.org/#domimplementation
class DOMImplementation {
	DocumentType createDocumentType(DOMString qualifiedName, DOMString publicId, DOMString systemId) {
		return new DocumentType(qualifiedName, publicId, systemId);
	}
	
	XMLDocument createDocument(
		DOMString namespace, 
		DOMString qualifiedName, /*[LegacyNullToEmptyString]*/
		DocumentType doctype=null 
	) {
		auto document = new XMLDocument();

		if( qualifiedName.length ) {
			document.documentElement = internalCreateElementNS(document,namespace,qualifiedName);
		}

		if( doctype !is null ) {
			document.doctype = doctype;
		}

		//TODO origin

		switch(namespace) {
			case Namespace.HTML:
				document.contentType = "application/xhtml+xml";
				break;

			case Namespace.SVG:
				document.contentType = "image/svg+xml";
				break;
				
			default:
				document.contentType = "application/xml";
				break;
		}

		return document;
	}
	
	//TODO [NewObject] Document createHTMLDocument(optional DOMString title);

	bool hasFeature() { return true; }; // useless; always returns true
} 