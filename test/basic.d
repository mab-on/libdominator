module test.basic;

import std.file : readText;
import std.path : dirName;
import std.format : format;
import libdominator;

unittest
{
	Document doc = readText( dirName(__FILE_FULL_PATH__)~"/basic.html" ).parse();

	assert( doc.doctype.nodeName() == "html" );
	assert( doc.documentElement.nodeName() == "HTML", format!"unexpected '%s'"(doc.documentElement.nodeName()) );

}
