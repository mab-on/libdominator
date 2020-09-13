module libdominator.xpath.nodeset;

import libdominator.dom.node.node;

struct Nodeset {
	Node[] _nodes;
	alias _nodes this;

	public this(Node[] nodes) {
		this._nodes = nodes;
	}

	Nodeset add(Node node) {
		import std.algorithm.searching : canFind;
		if( ! canFind(this._nodes, node) ) {
	    	this._nodes ~= node;
		}
	    return this;
	}

	Nodeset opOpAssign(string op : "~")(Node node) {
		return this.add(node);
	}

	void opAssign(Node[] nodes) {
		this._nodes.length = 0;
		foreach(node ; nodes) {
			this.add(node);
		}
	}
}
