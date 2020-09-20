module test.dom.node.node;

import libdominator.dom;

/// Node.parentElement()
unittest
{
	auto doc = `<root> <child></child> </root>`.parse();
    assert( null is doc.parentElement() );
    assert( null !is doc.firstChild().parentElement() );
}

/// nextSibling
unittest {
	auto doc = `
	<bros>
		<vinecent>Vince</vinecent>
		<oliver>Oli</oliver>
	</bros>
	`.parse();

	assert( null is doc.nextSibling() );

	auto vince = doc.firstChild();
	assert(vince.textContent() == "Vince");

	auto oli = vince.nextSibling();
	assert( oli.textContent() == "Oli" );
}
