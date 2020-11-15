module test.dom.node.node;

import libdominator.dom;

/// Node.parentElement()
unittest
{
	import std.format : format;

	auto doc = `<root> <child></child> </root>`.parse();
    assert( null is doc.documentElement.parentElement() );
    assert(
    	null !is doc.documentElement.firstChild().parentElement(),
    	format!("got unexpected '%s'")(doc.firstChild())
	);
}

/// nextSibling & previousSibling
unittest {
	auto doc = `
	<bros>
		<vinecent>Vince</vinecent>
		<oliver>Oli</oliver>
	</bros>
	`.parse();

	assert( null is doc.documentElement.nextSibling() );

	auto vince = doc.documentElement.firstChild();
	assert(vince.textContent() == "Vince");

	auto oli = vince.nextSibling();
	assert( oli.textContent() == "Oli" );

	assert( vince == oli.previousSibling() );
	assert( vince.previousSibling() is null );
}
