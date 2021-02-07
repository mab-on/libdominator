module test.dom.types.htmlcollection;


import libdominator.dom;
import libdominator.types;

import std.format;
import std.stdio;

unittest {
	auto firstForm = new Element("form");
	firstForm.setAttribute("id", "first-id");
	firstForm.setAttribute("name", "first");

	auto secondForm = new Element("form");
	secondForm.setAttribute("id", "second_id");
	secondForm.setAttribute("name", "second");

	auto collection = new HTMLCollection();
	collection._elements = [firstForm, secondForm];

	assert( collection.length == 2 );
	assert( collection[0].id == "first-id" );
	assert( collection[1].id == "second_id" );

	assert( collection["first-id"].id == "first-id" );
	assert( collection["first"].id == "first-id" );

	assert( collection.second_id.id == "second_id" );
	assert( collection.second.id == "second_id" );
}