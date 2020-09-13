module test.dom.parser.parser;

import libdominator.dom;

unittest
{
    assert(`<tag key=value fasel ding=dang\ dong >text</tag>`.parse.outerHTML
        == `<tag key=value fasel ding=dang\ dong>text</tag>`);

    assert(`<tag key=value single='quotes' double="quotes" >text</tag>`.parse.getAttributes
        == [
            Attribute("key","value",0x00),
            Attribute("single","quotes",'\''),
            Attribute("double","quotes",'"')
        ]);

    assert(`<tag keyA = valueA keyB="valB.1 valB.2" flag > text</tag>`.parse.getAttributes
        == [
            Attribute("keyA","valueA",0x00),
            Attribute("keyB","valB.1 valB.2", '"'),
            Attribute("flag","")
        ]);
}
