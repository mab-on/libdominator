module test.xpath.nodeset;

import libdominator.xpath.nodeset;

/// Nodeset maintains a set of unique nodes while adding
unittest {
	import libdominator.dom.node;

  	Node A = new Element("A");
  	Node B = new Element("B");
  	Node CA = A;

	Nodeset set;
  	set ~= A;
  	set ~= B;
  	set ~= CA;

	assert(set.length == 2);
}

/// ditto
unittest {
	import libdominator.dom.node;

	Node A = new Element("A");
  	Node B = new Element("B");
  	Node CA = A;

	Node[] list = [A,B,CA];

	Nodeset set;
	set = list;

	assert(set.length == 2);
}
