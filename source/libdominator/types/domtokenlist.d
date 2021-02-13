module libdominator.types.domtokenlist;

import libdominator.dom.errors;
import libdominator.dom.node.attribute;
import libdominator.dom.node.element;
import libdominator.types.domstring; 

private void enforceToken(ref DOMString token) {
	import std.algorithm.searching : any;
	import std.string : strip;
	import std.uni : isWhite;

	token = strip(token);
	if(token.length == 0) {
		throw new SyntaxError();
	}
	if( any!(isWhite)(token) ) {
		throw new InvalidCharacterError();
	}
}

// https://dom.spec.whatwg.org/#domtokenlist
class DOMTokenList {
	
	DOMString[] token_set;
	alias token_set this;

	DOMString attr_local_name;
	Element ownerElement;

	this(Element ownerElement, DOMString attr_local_name) {
		this.ownerElement = ownerElement;
		this.attr_local_name = attr_local_name;

		Attr attr = this.ownerElement.getAttributeNode(this.attr_local_name);
		if(attr !is null) {
			this.value( attr.value );
		}
	}

	size_t length() {
		return this.token_set.length;
	}

	DOMString item(size_t index) {
		return index < this.token_set.length
			? this.token_set[index]
			: null;
	}

	bool contains(DOMString token) {
		enforceToken(token);
		foreach( DOMString t; this.token_set ) {
			if(t == token) return true;
		}
		return false;
	}

	void add(DOMString[] tokens...) {
		foreach(DOMString token; tokens) {
			enforceToken(token);
			if(!this.contains(token)) {
				this.token_set ~= token;
			}
		}

		Attr attr = this.ownerElement.getAttributeNode(this.attr_local_name);
		if(attr is null) {
			attr = this.ownerElement.setAttributeNode(new Attr(this.attr_local_name));
		}

		attr.value = this.value();
	}

	void remove(DOMString[] tokens...) {
		Attr attr = this.ownerElement.getAttributeNode(this.attr_local_name);
		if(attr is null) {
			return;
		}

		DOMString[] new_set;
		bool rm;
		foreach(old; this.token_set) {
			rm = false;
			foreach(candi; tokens) {
				enforceToken(candi);
				if(candi == old) {
					rm = true;
					break;
				}
			}
			if( ! rm) {
				new_set ~= old;
			}
		} 
		
		this.token_set = new_set;
		attr.value = this.value();
	}

	bool toggle(DOMString token, bool force=false) {
		enforceToken(token);
		if(force) {
			this.add(token);
			return true;
		}
		if(this.contains(token)) {
			this.remove(token);
			return false;
		}
		this.add(token);
		return true;
	}

	bool replace(DOMString token, DOMString newToken) {
		enforceToken(token);
		if( ! this.contains(token)) {
			return false;
		}
		this.remove(token);
		this.add(newToken);
		return true;
	}

	@property DOMString value(DOMString token) {
		import std.string : split;
		this.token_set.length = 0;
		this.add(split(token));
		return this.value();
	}
	@property DOMString value() {
		import std.string : join;
		return this.token_set.join(" ");
	}	

	DOMString opIndex(size_t index) {
		return this.token_set[index];
	}
}
