module libdominator.dom.namespaces;

import std.conv;
import std.typecons;
import std.algorithm.searching : findSplit;

import libdominator.types;
import libdominator.dom;

private immutable ushort[] AllowedCodepointRanges = [

	//NameStartChar
	58, 58, //:
	65, 90, //A-Z
	95, 95, //_
	97, 122, //a-z
	0xC0, 0xD6,
	0xD8, 0xF6,
	0xF8, 0x2FF,
	0x370, 0x37D,
	0x37F, 0x1FFF,
	0x200C, 0x200D,
	0x2070, 0x218F,
	0x2C00, 0x2FEF,
	0x3001, 0xD7FF,
	0xF900, 0xFDCF,
	0xFDF0, 0xFFFD,

	//NameChar
	0x2D, 0x2D, // "-"
	0x2E, 0x2E,  // "."
	0x30, 0x39, // [0-9]
	0xB7, 0xB7, // ·
	0x0300, 0x036F,
	0x203F, 0x2040
];


//https://infra.spec.whatwg.org/#namespaces
enum Namespace : DOMString
{
	HTML = "http://www.w3.org/1999/xhtml",
	MathML = "http://www.w3.org/1998/Math/MathML",
	SVG = 	"http://www.w3.org/2000/svg",
	XLink = "http://www.w3.org/1999/xlink",
	XML = "http://www.w3.org/XML/1998/namespace",
	XMLNS = "http://www.w3.org/2000/xmlns/"
}


private bool validateChar(wchar c, immutable ushort[] rangelist) {
	ushort p = c.to!ushort;
	for(auto i=0; i < rangelist.length ; i+=2 ) {
		if(p >= rangelist[i] && p <= rangelist[1+i]) {
			return true;
		}
	}
	return false;
}

bool validate(DOMString qualifiedName) {
	foreach(i,c; qualifiedName) {
		if(i == 0) {
			if( ! validateChar(c, AllowedCodepointRanges[0..30])) {
				return false;
			}
		} else {
			if( ! validateChar(c, AllowedCodepointRanges)) {
				return false;
			}
		}

	} 
	return true;
}

alias ExtractResult = Tuple!(
	DOMString, "namespace", 
	DOMString, "prefix",
	DOMString, "localName"
);

// https://dom.spec.whatwg.org/#namespaces
ExtractResult validateAndExtract(DOMString namespace, DOMString qualifiedName) {
	if( ! namespace.length) {
		namespace = null;
	}

	if(! validate(qualifiedName)) {
		throw new InvalidCharacterError();
	}

	DOMString prefix = null;
	DOMString localName = qualifiedName;

	if(auto result = qualifiedName.findSplit(":"))
    {
      prefix = result[0];
      localName = result[2];
    }
    else
    {
      prefix = "";
      localName = qualifiedName;
    }

    if( prefix !is null && namespace is null) {
    	throw new NamespaceError();
    }

    if( prefix == "xml" && namespace != Namespace.XML ) {
    	throw new NamespaceError();
    }

    if( (prefix == "xmlns" || qualifiedName == "xmlns") && namespace != Namespace.XMLNS ) {
    	throw new NamespaceError();	
    }

    if( namespace == Namespace.XMLNS && !(prefix == "xmlns" || qualifiedName == "xmlns") ) {
    	throw new NamespaceError();
    }

    return ExtractResult(namespace, prefix, localName);
}

// https://dom.spec.whatwg.org/#concept-create-element
// TODO complete implementation - for now, its very basic
Element internalCreateElementNS(
	Document document, 
	DOMString namespace, 
	DOMString qualifiedName 
	// TODO options
) {
	auto extracted = validateAndExtract(namespace, qualifiedName);
	return new Element(document, extracted.localName ,extracted.namespace, extracted.prefix);
}