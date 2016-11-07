/**
 * Copyright:
 * (C) 2016 Martin Brzenska
 *
 * License:
 * Distributed under the terms of the MIT license.
 * Consult the provided LICENSE.md file for details
 */
module libdominator.Dominator;

import std.regex : regex, matchAll;
import std.conv : to;

import libdominator.Attribute;
import libdominator.Node;

struct comment
{
    uint begin;
    uint end;
}

struct terminator
{
    uint position;
    ushort length;
}

bool isBetween(size_t needle, size_t from, size_t to)
{
    return (needle > from && needle < to);
}

///Parse, hierarchize, analyse xhtml
class Dominator
{
    private auto rNode = regex(`<([\w\d-]+)(?:[\s]*|[\s]+([^>]+))>`, "i");
    private auto rAttrib = regex(`([\w\d-_]+)(?:=((")(?:\\"|[^"])*"|(')(?:\\'|[^'])*'|(?:\\[\s]|[^\s])*([\s])*))?`, "i");
    private auto rComment = regex(`<!--.*?-->`, "s");
    private string haystack;
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

    private void parse()
    {
        import std.string : chomp, chompPrefix;
        foreach (mComment; matchAll(this.haystack, this.rComment))
        {
            this.comments ~= comment(to!uint(mComment.pre().length),
                    to!uint(mComment.pre().length) + to!uint(mComment.front.length));
        }
        terminator[][string] terminators;
        foreach (mNode; matchAll(this.haystack, this.rNode))
        {
            auto node = new Node();
            node.setStartTagLength(mNode.front.length);
            mNode.popFront();
            node.setTag(mNode.front).setStartPosition(mNode.pre().length);
            foreach (comment cmnt; this.comments)
            {
                if (isBetween(node.getStartPosition(), cmnt.begin, cmnt.end))
                {
                    node.isComment(true);
                }
            }
            if (!mNode.empty)
            {
                mNode.popFront();
                foreach (mAttrib; matchAll(mNode.front, this.rAttrib))
                {
                    node.addAttribute(
                        Attribute(
                            mAttrib[1],
                            chompPrefix(
                                chomp(
                                    mAttrib[2],
                                    mAttrib[3] ~ mAttrib[4] ~ mAttrib[5]
                                ),
                                mAttrib[3] ~ mAttrib[4] ~ mAttrib[5]
                            )
                        )
                    );
                }
            }
            this.addNode(node);

            //search Terminator Candidates
            if (node.getTag() !in terminators)
            {
                foreach (mTerminatorCandi; matchAll(this.haystack[node.getStartPosition() .. $],
                        regex(r"</" ~ node.getTag() ~ ">","i")))
                {
                    terminators[node.getTag()] ~= terminator(node.getStartPosition() + to!uint(mTerminatorCandi.pre()
                            .length), to!ushort(mTerminatorCandi.front.length));
                }
                if (node.getTag() !in terminators)
                {
                    terminators[node.getTag()] ~= [terminator(node.getStartPosition(), 0)];
                }
            }
        }
        this.hierarchize(terminators);
    }

    private void addNode(Node node)
    {
        this.nodes ~= node;
    }

    private void hierarchize(terminator[][string] terminators)
    {
        import std.algorithm : sort;

        bool[size_t] arrTerminatorBlacklist;
        foreach_reverse (Node node; this.nodes)
        {
            terminator _lastTerm = terminator(node.getStartPosition(), 0);
            bool isTerminated = false;
            foreach_reverse (terminator terminatorCandi; terminators[node.getTag()])
            {
                if (terminatorCandi.position in arrTerminatorBlacklist)
                {
                    continue;
                }
                if (node.getStartPosition() > terminatorCandi.position)
                {
                    arrTerminatorBlacklist[_lastTerm.position] = true;
                    node.setEndPosition(_lastTerm.position).setEndTagLength(0);
                    isTerminated = true;
                    break;
                }
                else
                {
                    _lastTerm = terminatorCandi;
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

        Node[] sortedNodes;
        foreach (node; sort!"a.getStartPosition() < b.getStartPosition()"(this.nodes))
        {
            sortedNodes ~= node;
        }
        this.nodes = sortedNodes.dup;
        delete sortedNodes;

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
    public string getElelment(Node node)
    {
        return this.haystack[node.getStartPosition() .. (
                node.getEndPosition() + node.getEndTagLength())];
    }

    /**
     gets the Inner-HTML from the given node

     Params:
        node = The Node from which you want to get the Inner-HTML
    */
    public string getInner(Node node)
    {
        return (node.getEndPosition() > (node.getStartPosition() + node.getStartTagLength())) ? this.haystack[(
                node.getStartPosition() + node.getStartTagLength()) .. (node.getEndPosition())] : "";
    }
}

version(unittest) {
    import libdominator.Filter;
    import std.file;
}

unittest {
    const string content = `<div id="div-2-div-1">
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

unittest {
    import std.conv : to;
    Dominator dom = new Dominator(readText("dummy.html"));
    auto filter = DomFilter("article");
    assert( dom.filterDom(filter).filterComments().length == 3 , to!(string)(dom.filterDom(filter).filterComments().length) );
    assert( dom.filterDom(filter).length == 6 , to!(string)(dom.filterDom(filter).length));

    filter = DomFilter("div.*.ol.li");
    assert( dom.filterDom(filter).length == 3 );

    filter = DomFilter("div.ol.li");
    assert( dom.filterDom(filter).length == 6 );

    filter = DomFilter("ol.li");
    assert( dom.filterDom(filter).length == 6 );

    filter = DomFilter(`ol.li{id:(regex)^li-[\d]+}`);
    assert( dom.filterDom(filter).length == 6 );

    filter = DomFilter(`ol{id:ol-1}.li{id:(regex)^li-[\d]+}`);
    assert( dom.filterDom(filter).length == 3 );

    filter = DomFilter(`*{checked:}`);
    assert( dom.filterDom(filter).length == 1 );

    filter = DomFilter(`onelinenested`);
    assert( dom.filterDom(filter).length == 2 );

    filter = DomFilter(`onelinenested{class:level1}`);
    assert( dom.filterDom(filter).length == 1 );

    filter = DomFilter(`onelinenested{class:level2}`);
    assert( dom.filterDom(filter).length == 1 );

    filter = DomFilter(`onelinenested.onelinenested`);
    assert( dom.filterDom(filter).length == 1 );

    /**
    * Find the nodes with a special href.
    */
    filter = DomFilter(`*{href:https://www.google.com/support/contact/user?hl=en}`);
    assert( dom.filterDom(filter).length);
    foreach(Node foundNode ; dom.filterDom(filter)) {
        assert (Attribute("href","https://www.google.com/support/contact/user?hl=en").matches(foundNode) );
    }

    /**
    * Find the nodes with a special href - In HTML5 it is ok to have attribute-values without quotation marks.
    */
    filter = DomFilter(`*{href://www.google.com/}`);
    assert( dom.filterDom(filter).length);
    foreach(Node foundNode ; dom.filterDom(filter)) {
        assert( Attribute("href","//www.google.com/").matches(foundNode) );
    }
}
