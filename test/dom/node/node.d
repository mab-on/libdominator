module test.dom.node.node;

import libdominator.dom;

/// Node.parentElement()
unittest
{
	auto doc = `<root> <child></child> </root>`.parse();
    assert( null is doc.parentElement() );
    assert( null !is doc.firstChild().parentElement() );
}
