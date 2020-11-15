module libdominator.dom.node.parentnode;

import libdominator.dom.node.element : Element;
import libdominator.dom.nodetree.nodelist;

/**
* See_Also:
* 	https://www.w3.org/TR/2018/WD-dom41-20180201/#parentnode
*	https://dom.spec.whatwg.org/#parentnode
*/
interface ParentNode {

	/**
	* The firstElementChild attribute’s getter must return the first child that is an element, and null otherwise.
	*/
	Element firstElementChild();
	NodeList children(); //https://dom.spec.whatwg.org/#dom-parentnode-children
}

mixin template ParentNodeMixin() {
	import libdominator.dom.node.element : Element;

	public Element firstElementChild() {
		foreach( node ; this.childNodes() ) {
		  if( typeid(node) is typeid(Element) ) return cast(Element)node;
		}
		return null;
	}

	NodeList children() {
		import std.algorithm.iteration : filter;
		import std.array : array;
		return this.childNodes().filter!(node => typeid(node) == typeid(Element) ).array();
	}

}
