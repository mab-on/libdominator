module test.dom.parser.parser;

import libdominator.dom;
import std.format;

import std.stdio;

unittest
{
    auto probe = `<tag key=value fasel ding=dang\ dong >text</tag>`.parse();
    assert(probe.documentElement.attributes.length == 3, format!"unexpected '%d'"(probe.documentElement.attributes.length));
    assert(probe.toString()
        == `<tag key=value fasel ding=dang\ dong>text</tag>`,
        format!"unexpected '%s'"(probe.toString()));

    auto attribs = `<tag key=value single='quotes' double="quotes" >text</tag>`.parse().documentElement.attributes.values;
    assert(attribs[0].name == "key" && attribs[0].value == "value" && attribs[0]._wrapper == 0x00);
    assert(attribs[1].name == "single" && attribs[1].value == "quotes" && attribs[1]._wrapper == '\'');
    assert(attribs[2].name == "double" && attribs[2].value == "quotes" && attribs[2]._wrapper == '"');

    auto element = `<tag keyA = valueA keyB="valB.1 valB.2" flag > text</tag>`.parse().documentElement;
    assert( element.getAttributeNode("keyA").value == "valueA" );
    //assert(attribs[0].name == "keyA" && attribs[0].value == "valueA" && attribs[0]._wrapper == 0x00);
    //assert(attribs[1].name == "keyB" && attribs[1].value == "valB.1 valB.2" && attribs[1]._wrapper == '"');
    //assert(attribs[2].name == "flag");

}
