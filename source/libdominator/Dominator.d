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
    return (needle >= from && needle <= to);
}

class Dominator
{
    private auto rNode = regex(`<([\w\d-]+)(?:[\s]*|[\s]+([^>]+))>`, "i");
    private auto rAttrib = regex(`([\w\d-_]+)=((")(?:\\"|[^"])*"|(')(?:\\'|[^'])*')`, "i");
    private auto rComment = regex(`<!--.*-->`, "g");
    private string haystack;
    private comment[] comments;

    private Node[] nodes;
    ;

    this()
    {
    }

    this(string haystack)
    {
        this.load(haystack);
    }

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
                    node.addAttribute(Attribute(mAttrib[1],
                            chompPrefix(chomp(mAttrib[2],
                            mAttrib[3] ~ mAttrib[4]), mAttrib[3] ~ mAttrib[4])));
                }
            }
            this.addNode(node);

            //search Terminator Candidates
            if (node.getTag() !in terminators)
            {
                foreach (mTerminatorCandi; matchAll(this.haystack[node.getStartPosition() .. $],
                        regex(r"</" ~ node.getTag() ~ ">")))
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

    public void addNode(Node node)
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
            foreach_reverse (size_t t, terminator terminatorCandi; terminators[node.getTag()])
            {
                if (terminatorCandi.position in arrTerminatorBlacklist)
                {
                    continue;
                }
                if (node.getStartPosition() > terminatorCandi.position)
                {
                    arrTerminatorBlacklist[_lastTerm.position] = true;
                    node.setEndPosition(_lastTerm.position)
                        .setEndTagLength(to!ushort(terminatorCandi.length));
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

    public Node[] getNodes()
    {
        return this.nodes;
    }

    public string getStartElement(Node node)
    {
        return this.haystack[node.getStartPosition() .. (
                node.getStartPosition() + node.getStartTagLength())];
    }

    public string getElelment(Node node)
    {
        return this.haystack[node.getStartPosition() .. (
                node.getEndPosition() + node.getEndTagLength())];
    }

    public string getInner(Node node)
    {
        return (node.getEndPosition() > (node.getStartPosition() + node.getStartTagLength())) ? this.haystack[(
                node.getStartPosition() + node.getStartTagLength()) .. (node.getEndPosition())] : "";
    }
}
