module libdominator.dom.node.parentnode;

import libdominator.dom.node.element : Element;

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
	
}