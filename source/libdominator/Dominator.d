/**
 * Copyright:
 * (C) 2016 Martin Brzenska
 *
 * License:
 * Distributed under the terms of the MIT license.
 * Consult the provided LICENSE.md file for details
 */
module libdominator.Dominator;

import std.conv : to;

import libdominator.Attribute;
import libdominator.Node;

version(unittest) {
    import libdominator.Filter;
    import std.file;
}

struct comment
{
    size_t begin;
    size_t end;
}

struct terminator
{
    size_t position;
    size_t length;
}

pragma(inline,true):
bool isBetween(in size_t needle, in size_t from, in size_t to)
{
    return (needle > from && needle < to);
}

///Parse, hierarchize, analyse xhtml
class Dominator
{
    private string haystack;
    private size_t needle;
    private comment[] comments;

    private Node[] nodes;

    /**
     Instantiate empty Dominator
    */
    this() {}

    /**
     Instantiate object and load the Document
    */
    this(string haystack)
    {
        this.load(haystack);
    }

    /**
     loads a Document
     Params:
       haystack = the Document String
    */
    public Dominator load(string haystack)
    {
        this.haystack = haystack;
        this.parse();
        return this;
    }

    private bool tryElementOpener(ref Node node, ref size_t needle) {
        import std.ascii : isWhite , isAlphaNum , isAlpha;
        enum ParserStates : ubyte {
            name = 1,
            key = 2,
            value = 4,
            err = 8,
            ready = 16
        }
        ubyte state = 0;

        char inQuote = 0x00;
        size_t nameCoord;
        size_t[2] keyCoord, valCoord;

        if(this.haystack[needle] != '<') {
            return false;
        }
        node.setStartPosition(needle);
        needle++;

        /*
        * parse the elements name
        */
        //first, skip whitespaces
        while(needle < this.haystack.length && this.haystack[needle].isWhite) { needle++; }

        //The name begins with a underscore or a alphabetical character.
        if(
            ! this.haystack[needle].isAlpha
            && ! this.haystack[needle] == '_'
        ) {
            return false;
        }
        nameCoord = needle;

        //The name can contain letters, digits, hyphens, underscores, and periods
        for(; needle < this.haystack.length && !this.haystack[needle].isWhite ; ++needle) {
            if(
                ! this.haystack[needle].isAlphaNum
                &&  this.haystack[needle] != '-'
                &&  this.haystack[needle] != '_'
                &&  this.haystack[needle] != '.'
                &&  this.haystack[needle] != ':'
            ) {
                if(this.haystack[needle] == '>') {
                    state |= ParserStates.ready;
                    break;
                } else {
                    return false;
                }
            }
        }
        node.setTag(this.haystack[nameCoord..needle]);
        state |= ParserStates.name;

        /*
        * Parse attributes
        */
        while( ! (state & ParserStates.ready))
        {
            //reset state
            state &= ~(ParserStates.key | ParserStates.value);

            //Check if the next non-whitespace char finishes our job here
            while(needle < this.haystack.length && this.haystack[needle].isWhite){ needle++; }
            if(this.haystack[needle] == '>') {
                state |= ParserStates.ready;
                break;
            }
            /*
            * Find the attr-key
            */
            keyCoord[0] = needle;
            for(; needle < this.haystack.length && !this.haystack[needle].isWhite ; ++needle) {
                if(this.haystack[needle] == '>') {
                    state |= ParserStates.ready;
                    break;
                }
                if(this.haystack[needle] == '=') {
                    break;
                }
            }
            keyCoord[1] = needle;

            if(state & ParserStates.ready) {
                node.addAttribute( Attribute(this.haystack[keyCoord[0]..keyCoord[1]] , "" ) );
            }
            else {
                /**
                * Parse attribute value if exist
                */

                //skip whitespaces
                while(needle < this.haystack.length && this.haystack[needle].isWhite) { needle++; }

                if(this.haystack[needle] == '>') {
                    //there is no value and this is the end
                    state |= ParserStates.ready;
                    node.addAttribute( Attribute(this.haystack[keyCoord[0]..keyCoord[1]] , "" ) );
                    break;
                }
                else if(this.haystack[needle] == '=')
                {
                    //here comes the value...
                    needle++;
                    while(needle < this.haystack.length && this.haystack[needle].isWhite) { needle++; }
                    if(this.haystack[needle] == '"' || this.haystack[needle] == '\'' ) {
                        //quoted value
                        inQuote = this.haystack[needle];
                        needle++;
                        valCoord[0] = needle;
                        while(
                            needle < this.haystack.length
                            && (this.haystack[needle] != inQuote
                            || ( this.haystack[needle] == inQuote && this.haystack[needle-1] == '\\'))
                        ) {
                            needle++;
                        }
                        valCoord[1] = needle;
                        needle++;
                    }
                    else {
                        //not quoted value
                        inQuote = 0x00;
                        valCoord[0] = needle;
                        while(
                            needle < this.haystack.length
                            && (!this.haystack[needle].isWhite
                            || ( this.haystack[needle].isWhite && this.haystack[needle-1] == '\\'))
                        ) {
                            if(this.haystack[needle] == '>') {
                                state |= ParserStates.ready;
                                break;
                            }
                            needle++;
                        }
                        if(state & ParserStates.ready) {
                            valCoord[1] = needle;
                        }
                        else {
                            valCoord[1] = needle;
                            needle++;
                        }
                    }
                }
                else {
                    //there is no value
                }
                if(keyCoord[1] >= this.haystack.length || valCoord[1] >= this.haystack.length) {
                    return false;
                }
                node.addAttribute(Attribute(
                    this.haystack[keyCoord[0]..keyCoord[1]],
                    this.haystack[valCoord[0]..valCoord[1]]
                ));
            }
        }
        node.setStartTagLength( 1 + needle - node.getStartPosition() );
        return true;
    }

    private bool tryElementTerminator(ref terminator[][string] terminators , ref size_t needle) {
        import std.ascii : isWhite;
        import std.uni : toLower;
        if( this.haystack[needle] != '<' ) {return false;}

        size_t[2] nameCoord;
        size_t position = needle;

        for(needle = needle + 1; needle < this.haystack.length && this.haystack[needle].isWhite ; needle++) {}
        if(this.haystack[needle] != '/') { return false; }
        nameCoord[0] = 1 + needle;
        for(
            needle = needle + 1 ;
            needle < this.haystack.length
            && !this.haystack[needle].isWhite ;
            needle++
        ) {
            if(this.haystack[needle] == '>') {
                terminators[this.haystack[nameCoord[0]..needle].toLower] ~= terminator(position , 1 + needle - position);
                return true;
            }
        }
        nameCoord[1] = needle;
        for(; needle < this.haystack.length && this.haystack[needle].isWhite ; needle++) {}
        if(this.haystack[needle] == '>') {
            terminators[this.haystack[nameCoord[0]..nameCoord[1]].toLower] ~= terminator(position , 1 + needle - position);
            return true;
        }
        return false;
    }

    private bool tryCommentOpener(ref size_t needle) {
        if(
            needle + 4 < this.haystack.length
            && this.haystack[needle..needle+4] == "<!--"
        ) {
            needle = needle+4;
            return true;
        }
        return false;
    }
    private bool tryCommentTerminator(ref size_t needle) {
        if(
            needle + 3 < this.haystack.length
            && this.haystack[needle..needle+3] == "-->"
        ) {
            needle = needle+3;
            return true;
        }
        return false;
    }
    private void parse()
    {
        import std.ascii : isWhite , isAlphaNum , isAlpha;
        import std.array : appender;

        //Reset parsed state
        this.nodes = [];
        this.comments = [];

        if(this.haystack.length == 0) { return; }
        Node[] nodes;
        auto nodeAppender = appender(nodes);
        terminator[][string] terminators;
        size_t needleProbe;
        enum ParserStates : ubyte {
            inElementOpener = 1,
            inComment = 2
        }
        ubyte state;
        size_t needle;

        do {
            if(this.haystack[needle] == '<') {

                needleProbe = needle;
                if( this.tryElementTerminator(terminators , needleProbe) ) {
                    needle = needleProbe;
                    continue;
                }

                needleProbe = needle;
                if(
                    !(state & ParserStates.inComment)
                    && this.tryCommentOpener(needleProbe)
                ) {
                    needle = needleProbe;
                    state |= ParserStates.inComment;
                    continue;
                }

                needleProbe = needle;
                Node elem = new Node();
                if( this.tryElementOpener(elem , needleProbe) ) {


                    needle = needleProbe;
                    if(state & ParserStates.inComment) {elem.isComment(true);}
                    nodeAppender.put(elem);
                    continue;
                }

            }
            else if(
                this.haystack[needle] == '-'
                && state & ParserStates.inComment
            ) {
                needleProbe = needle;
                if( this.tryCommentTerminator(needleProbe) ) {
                    needle = needleProbe;
                    state &= ~ParserStates.inComment;
                    continue;
                }
            }

            needle++;
        } while(needle < this.haystack.length);

        this.nodes = nodeAppender.data;
        this.hierarchize(terminators);
    }

    private void hierarchize(terminator[][string] terminators)
    {
        import std.algorithm.sorting : sort;

        bool[size_t] arrTerminatorBlacklist;
        foreach_reverse (Node node; this.nodes)
        {
            terminator _lastTerm = terminator(node.getStartPosition(), 0);
            bool isTerminated = false;

            if(node.getTag() in terminators) {
                foreach_reverse (terminator terminatorCandi; terminators[node.getTag()])
                {
                    if (terminatorCandi.position in arrTerminatorBlacklist)
                    {
                        //skip if already checked and marked as a false candidate
                        continue;
                    }
                    if (node.getStartPosition() > terminatorCandi.position)
                    {
                        /*
                        * The candidates position is lower then the position of the node, for which we are searching the terminator.
                        * This means, that the last candidate, that we have checked, was the right one - if there was one.
                        */
                        arrTerminatorBlacklist[_lastTerm.position] = true;
                        node.setEndPosition(_lastTerm.position).setEndTagLength(_lastTerm.length);
                        isTerminated = true;
                        break;
                    }
                    else
                    {
                        _lastTerm = terminatorCandi;
                    }
                }
            }
            if (!isTerminated)
            {
                node.setEndPosition(_lastTerm.position).setEndTagLength(_lastTerm.length);
                arrTerminatorBlacklist[_lastTerm.position] = true;
            }
            if (node.getEndTagLength == 0)
            {
                //No Terminator has been found - we assume, that this is a self-terminator
                node.setEndTagLength(node.getStartTagLength());
            }
        }

        this.nodes.sort!("a.getStartPosition() < b.getStartPosition()");

        foreach (size_t i, Node node; this.nodes)
        {
            for (size_t back = 1; back <= i; back++)
            {
                if (this.nodes[i - back].getEndPosition() > node.getEndPosition())
                {
                    node.setParent(&this.nodes[i - back]);
                    node.getParent().addChild(&this.nodes[i]);
                    break;
                }
            }
        }
    }

    /**
     returns all found Nodes.
     Please note, that also Nodes will be returned which was found in comments.
     use isComment() to check if a Node is in a comment or use libdominator.Filter.filterComments()

     returns:
      Nodes[]
    */
    public Node[] getNodes()
    {
        return this.nodes;
    }

    /**
     gets the Tag Name of the Node

     Params:
        node = The Node to get the Tag Name from

     Returns:
      The Tag Name as string
    */
    public string getStartElement(Node node)
    {
        return this.haystack[node.getStartPosition() .. (
                node.getStartPosition() + node.getStartTagLength())];
    }

    /**
     gets the part of the loaded Document from the nodes begining to its end

     Params:
        node = The Node from which you want to get the Document representation
    */
    public string getElement(Node node)
    {
        return this.haystack[node.getStartPosition() .. (
                node.getEndPosition() + node.getEndTagLength())];
    }

    /**
    * gets the Inner-HTML from the given node
    *
    * Params:
    *    node = The Node from which you want to get the Inner-HTML
    */
    public string getInner(Node node)
    {
        if ( node.getEndPosition() > (node.getStartPosition() + node.getStartTagLength()) )
        {
            return this.haystack[(node.getStartPosition() + node.getStartTagLength())..(node.getEndPosition())];
        }
        return "";
    }

    /**
    * Removes tags and returns plain inner content
    */
    public string stripTags(Node node) {
        import std.algorithm.searching : any;
        import std.array : appender;
        auto inner = appender!string();
        Node[] descendants = node.getDescendants();
        for(size_t i = node.getStartPosition + node.getStartTagLength ; i < node.getEndPosition ; i++) {
            if( !
                any!(desc =>
                isBetween(i , desc.getStartPosition()-1 , desc.getStartPosition()+desc.getStartTagLength())
                || isBetween(i , desc.getEndPosition()-1 , desc.getEndPosition()+desc.getEndTagLength())
                )(descendants)
            ) {
                inner.put(this.haystack[i]);
            }
        }
        return inner.data;
    }

    /**
    * Removes tags and returns plain inner content
    */
    public string stripTags() {
        if( ! this.nodes.length) {
            return "";
        }
        return this.stripTags((*this.nodes.ptr));
    }
    ///
    unittest {
        const string content = `<div><h2>bla</h2><p>fasel</p></div>`;
        Dominator dom = new Dominator(content);
        assert( dom.stripTags() == "blafasel", dom.stripTags());
    }
}

unittest {
    const string content = `<div data-function=">">
        <ol id="ol-1">
          <li id="li-1-ol-1">li-1-ol-1 Inner</li>
          <li id="li-2-ol-1">li-2-ol-1 Inner</li>
          <li id="li-3-ol-1">li-3-ol-1 Inner</li>
        </ol>
      </div>`;
      Dominator dom = new Dominator(content);
      assert( dom.getNodes.length == 5);
      assert( dom.filterDom(DomFilter("ol")).length == 1 );
      assert( dom.filterDom(DomFilter("ol.li")).length == 3 );
      assert( dom.filterDom(DomFilter("ol.li{id:li-3-ol-1}")).length == 1 );
}

/// get descendants of a specific Node and apply further filtering on the result.
unittest {
    const string content = `<div data-function="<some weird> stuff">
        <span>
            <span>
                <span>bäm!</span>
            </span>
            <span>boing!</span>
        </span>
        <ol id="ol-1">
          <li id="li-1-ol-1">li-1-ol-1 Inner</li>
          <li id="li-2-ol-1">li-2-ol-1 Inner</li>
          <li id="li-3-ol-1">li-3-ol-1 Inner</li>
        </ol>
      </div>`;

      Dominator dom = new Dominator(content);
      Node [] descendants = (*dom.filterDom("div").ptr).getDescendants();
      assert( descendants.filterDom("span").length == 4 );
      assert( descendants.filterDom("li").length == 3 );
      assert( descendants.filterDom("ol").length == 1 );
}

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
        </ol>
        <p>have a nice day</p>
    </div>`;
    Dominator dom = new Dominator(html);

    foreach(node ; dom.filterDom("ul.li")) {
        //do something more usefull with the node then:
        assert(node.getParent.getTag() == "ul");
    }

    Node[] nodes = dom.filterDom("ul.li");
    assert(dom.getInner( nodes[0] ) == "one" );
    assert(nodes[0].getAttributes() == [ Attribute("class","wanted") ] , to!(string)(nodes[0].getAttributes()) );
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

unittest {
    Dominator dom = new Dominator(readText("dummy.html"));
    auto filter = DomFilter("article");
    assert( dom.filterDom(filter).filterComments().length == 3 , to!(string)(dom.filterDom(filter).filterComments().length));
    assert( dom.filterDom(filter).length == 6);

    assert( dom.filterDom("div.*.ol.li").length == 3 );
    assert( dom.filterDom("div.ol.li").length == 6 );
    assert( dom.filterDom("ol.li").length == 6 );
    assert( dom.filterDom(`ol.li{id:(regex)^li-[\d]+}`).length == 6 );
    assert( dom.filterDom(`ol{id:ol-1}.li{id:(regex)^li-[\d]+}`).length == 3 );
    assert( dom.filterDom(`*{checked:}`).length == 1 );
    assert( dom.filterDom(`onelinenested`).length == 2 );
    assert( dom.filterDom(`onelinenested{class:level1}`).length == 1 );
    assert( dom.filterDom(`onelinenested{class:level2}`).length == 1 );
    assert( dom.filterDom(`onelinenested.onelinenested`).length == 1 );

    /**
    * Find nodes with a special href.
    */
    filter = DomFilter(`*{href:https://www.google.com/support/contact/user?hl=en}`);
    assert( dom.filterDom(filter).length);
    foreach(Node foundNode ; dom.filterDom(filter)) {
        assert (Attribute("href","https://www.google.com/support/contact/user?hl=en").matches(foundNode) );
    }

    /**
    * Find nodes with a special href - In HTML5 it is ok to have attribute-values without quotation marks.
    */
    filter = DomFilter(`*{href://www.google.com/}`);
    assert( dom.filterDom(filter).length);
    foreach(Node foundNode ; dom.filterDom(filter)) {
        assert( Attribute("href","//www.google.com/").matches(foundNode) );
    }
}
/*
* trouble with uppercase tags
*/
unittest
{
    Dominator dom = new Dominator(readText("dummy.html"));
    foreach(node ; dom.filterDom("scpdurl"))
    {
        assert( dom.getInner(node) == "/timeSCPD.xml" );
    }
}