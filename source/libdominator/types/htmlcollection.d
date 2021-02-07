module libdominator.types.htmlcollection;

import libdominator.dom.node.element;
import libdominator.types.domstring;

// https://dom.spec.whatwg.org/#htmlcollection
class HTMLCollection {
	Element[] _elements;
	alias _elements this;

	this() {}
	this(Element[] elements) {
		this._elements = elements;
	}

	size_t length() {
		return this._elements.length;
	}

  Element item(size_t index) {
  	return index < this._elements.length
  		? this._elements[index]
  		: null;
  }

  /// Returns the first element with ID or name $name from the collection. 
  Element namedItem(DOMString name) {
  	foreach(Element e ; this._elements) {
  		if( e.getAttribute("id") == name ) return e;
  		if( e.getAttribute("name") == name ) return e;
  	}
  	return null;
  }

  Element opIndex(size_t index) {
  	return this._elements[index];
  }

  Element opIndex(DOMString name) {
  	return this.namedItem(name);
  }

	Element opDispatch(DOMString name)() {
		return this.namedItem(name);
	}
};