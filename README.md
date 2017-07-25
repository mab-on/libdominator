# libdominator
libdominator is a xHTML parser library written in [d](http://www.dlang.org)

## usage
```D
/// basic example
unittest {
    const string html =
    `<div>
        <p>Here comes a list!</p>
        <ul>
            <li class="wanted">one</li>
            <!-- <li>two</li> -->
            <li class="wanted hard">three</li>
            <li id="item-4">four</li>
            <li checked>five</li>
            <li id="item-6">six</li>
        </ul>
        <p>another list</p>
        <ol>
            <li>eins</li>
            <li>zwei</li>
            <li>drei</li>
        <ol>
        <p>have a nice day</p>
    </div>`;

    Dominator dom = new Dominator(html);

    foreach(node ; dom.filterDom("ul.li")) {
        //do more usefull stuff then:
        assert(node.getParent.getTag() == "ul");
    }

    Node[] nodes = dom.filterDom("ul.li");
    assert(dom.getInner( nodes[0] ) == "one" );
    assert(nodes[0].getAttributes() == [ Attribute("class","wanted") ] );
    assert(Attribute("class","wanted").matches(nodes[0]));
    assert(Attribute("class","wanted").matches(nodes[2]));
    assert(Attribute("class",["wanted","hard"]).matches(nodes[2]));
    assert(nodes[1].isComment());

    assert(dom.filterDom("ul.li").length == 6);
    assert(dom.filterDom("ul.li").filterComments.length == 5);
    assert(dom.filterDom("li").length == 9);
    assert(dom.filterDom("li[1]").length == 1); //the first li in the dom
    assert(dom.filterDom("*.li[1]").length == 2); //the first li in ul and first li in ol
    assert(dom.getInner( (*dom.filterDom("*{checked:}").ptr) ) == "five");

}
```

# Filter Syntax
Expression = TAG[PICK]{ATTR_NAME:ATTR_VALUE}
Multiple expressions can be concatenated with "." to find stuff inside of specific parent nodes.

| Item | Description | Example |
|------|-------------|---------|
| TAG | The Name of the node | a , p , div , *  |
| [PICK] | (can be ommited) Picks only the n th match. n begins on 1. PICK can be a list or range | [1] picks the first match , [1,3] picks the first and third , [1..3] picks the first three matches  |
| {ATTR_NAME:ATTR_VALUE} | The attribute selector | {id:myID} , {class:someClass} , {href:(regex)^http://}  |

See also https://github.com/mab-on/dominator
