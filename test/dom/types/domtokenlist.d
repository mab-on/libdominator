module test.dom.types.domtokenlist;

import libdominator.dom.node.element;
import libdominator.types.domtokenlist;

unittest {
	auto para = new Element("p");
	para.className("a b c");
	assert(para.classList.length == 3);

	auto classes = para.classList;
	para.classList.add("d");
	assert(para.classList.length == 4);
	assert(para.classList.length == classes.length);
}

unittest {
	auto para = new Element("p");
	para.className("a b");

	para.classList.remove("b");
	assert(para.classList.length == 1);
}

unittest {
	auto para = new Element("p");
	para.className("a b");

	para.classList.toggle("b");
	assert(para.classList.length == 1);

	para.classList.toggle("b");
	assert(para.classList.length == 2);
}

unittest {
	auto para = new Element("p");
	para.className("a b");

	assert(para.classList.contains("a"));
	assert(para.classList.contains("b"));

	para.classList.replace("a" , "z");
	assert(para.classList.length == 2);
	assert(para.classList.contains("z"));
	assert(para.classList.contains("b"));
}