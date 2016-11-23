/**
 * Copyright:
 * (C) 2016 Martin Brzenska
 *
 * License:
 * Distributed under the terms of the MIT license.
 * Consult the provided LICENSE.md file for details
 */
module libdominator.Filter;

import std.regex : StaticRegex , ctRegex , matchAll , matchFirst;
import std.string : chompPrefix , chomp , strip;

import libdominator;

auto rDomFilterExpression = ctRegex!(`([\w\d*]+)(\[(?:[,]?[\d]+|[\d]\.\.[\d$])+\])?(?:\{([^\}]+)\})?`);
auto rRangePicks = ctRegex!(`([\d]+)\.\.([\d$]+)`);
auto rListPicks = ctRegex!(`[\d]+`);
auto rAttribExpression = ctRegex!(`([^:]+):([^,]+)*[,]?`);


enum FilterPicktype { list,range }

/**
* Use this to filter html
*/
struct DomFilter {
    import std.conv : to;
    import std.array : split;
    TagElement[] elements;
    size_t i;

    /**
    * A dominator specific array of filter expressions
    */
    this(string[] expressions)
    {
        foreach(string expression ; expressions)
        {
            this.addExpression(expression);
        }
    }
     /**
    * A dominator specific filter expression
    */
    this(string expression)
    {
        this.addExpression(expression);
    }

    private void addExpression(string expression)
    {
        foreach(capt ; matchAll(expression, rDomFilterExpression) ) {
            TagElement tagElement;

            capt.popFront();
            tagElement.name = capt.front;
            capt.popFront();
            if ( ! capt.empty)
            {
                auto pickCapt = matchFirst(capt.front, rRangePicks);
                if (!pickCapt.empty)
                {
                    tagElement.picktype = FilterPicktype.range;
                    tagElement.picks ~= to!short(pickCapt[1]);
                    tagElement.picks ~= (pickCapt[2] == "$") ? 0 : to!short(pickCapt[2]);
                }
                else
                {
                    tagElement.picktype = FilterPicktype.list;
                    foreach (mItem; matchAll(capt.front, rListPicks))
                    {
                        tagElement.picks ~= to!short(mItem.hit());
                    }
                }
            }
            capt.popFront();
            if( ! capt.empty && capt.front.length) {
                tagElement.attribs = parseAttributexpression(capt.front);
            }
            this.elements ~= tagElement;
        }
    }

    ///parses the attribute filter expression and boxes it into an handy array of Attribute
    Attribute[] parseAttributexpression(string expression) {
        Attribute[] attribs;
        foreach (mAttrib; matchAll(expression, rAttribExpression))
        {
            string key = chompPrefix(chomp(strip(mAttrib[1]), "\"'"), "\"'");
            string[] values;
            foreach (v; split(mAttrib[2]))
            {
                values ~= chompPrefix(chomp(strip(v), "\"'"), "\"'");
            }
            attribs ~= Attribute(key, values);
        }
        return attribs;
    }
    unittest {
        auto f = DomFilter();
        assert(f.parseAttributexpression("class:myClass,id:myID") == [Attribute("class", ["myClass"]), Attribute("id", ["myID"])]);
        assert(f.parseAttributexpression("class:myClass") == [Attribute("class", ["myClass"])]);
        assert(f.parseAttributexpression("data-url:http://www.mab-on.net/") == [Attribute("data-url", ["http://www.mab-on.net/"])]);
    }

    /**
    * Moves the cursor to the next TagElement if exists
    * Returns:
    *   true if the cursor could be moved, otherwise false
    */
    bool next() {
        if( 1 + this.i < this.elements.length ) {
            this.i++;
            return true;
        }
        return false;
    }

    /**
    * The current TagElement, which is under the cursor.
    * if there is no TagElement, then a empty TagElement will be returned.
    */
    TagElement front() {
        return this.elements.length ? this.elements[this.i] : TagElement() ;
    }

    ///The number of following TagElements after the current TagElement
    size_t followers() {
        return this.elements.length == 0 ? 0 : this.elements.length - 1 - this.i;
    }

    ///opApply on TagElements
    int opApply(int delegate(ref TagElement) dg)
    {
        int result = 0;
        for (int i = 0; i < this.elements.length; i++)
        {
            result = dg(this.elements[i]);
            if (result)
            {
                break;
            }
        }
        return result;
    }

    /**
    * Checks if there are any TagElements.
    * in other words: Checks if the DomFilter is loaded with some filterarguments or not.
    */
    bool empty() { return this.elements.length == 0; }

    unittest {
        DomFilter filter;
        assert(filter.empty == true);

        filter = DomFilter("p");
        assert(filter.elements == [TagElement(FilterPicktype.list, [], "p", [])]);

        filter = DomFilter("p[1,2]");
        assert(filter.elements == [TagElement(FilterPicktype.list, [1, 2], "p", [])]);

        filter = DomFilter("p[1..2]");
        assert(filter.elements == [TagElement(FilterPicktype.range, [1, 2], "p", [])]);

        filter = DomFilter("p[1]{class:MyClass}");
        assert(filter.elements == [TagElement(FilterPicktype.list, [1], "p", [Attribute("class", ["MyClass"])])]);

        filter = DomFilter("div.*.p[1..$]{class:MyClass}");
        assert(filter.elements == [
            TagElement(FilterPicktype.list, [], "div", []),
            TagElement(FilterPicktype.list, [], "*", []),
            TagElement(FilterPicktype.range, [1, 0], "p", [Attribute("class", ["MyClass"])])
        ]);

        filter = DomFilter("div.a{id:myID}.p[1..$]{class:MyClass}");
        assert(filter.elements == [
            TagElement(FilterPicktype.list, [], "div", []),
            TagElement(FilterPicktype.list, [], "a", [Attribute("id", ["myID"])]),
            TagElement(FilterPicktype.range, [1, 0], "p", [Attribute("class", ["MyClass"])])
        ]);
    }
}
/**
* The TagElement is the struct for the atomic part of a filter expression.
* Examples:
* ---------------
* a[1]{class:someClass}
* ---------------
*/
struct TagElement
{
    FilterPicktype picktype;
    ushort[] picks;
    string name;
    Attribute[] attribs;

    ///checks if the TagElement matches the given pick
    bool has(size_t pick)
    {
        if (picks.length == 0)
        {
            return true;
        }
        if(this.picktype == FilterPicktype.range) {
            if(this.picks[1] == 0 && this.picks[0] <= pick) { return true; }
            else if(isBetween(pick , this.picks[0] , this.picks[1])) { return true; }
        }
        else
        {
            foreach (size_t i; picks)
            {
                if (i == pick)
                {
                    return true;
                }
            }
        }
        return false;
    }
}

///Filters the given DOM and returns the nodes, that matches the given filter expression
Node[] filterDom(Dominator dom , DomFilter expressions) {
    return filterDom(dom,[expressions]);
}

///Filters the given DOM and returns the nodes, that matches the given filter expressions
Node[] filterDom(Dominator dom , DomFilter[] expressions) {
    return dom.getNodes().filterDom(expressions);
}

///Filters the given nodes and returns the nodes, that matches the given filter expressions
Node[] filterDom(Node[] nodes , DomFilter[] expressions) {
    if(expressions.length == 0) {return nodes;}
    Node[] resultNodes;
    foreach(DomFilter exp ; expressions) {
       resultNodes ~= filterDom(nodes , exp);
    }
    return resultNodes;
}

///Filters the given nodes and returns the nodes, that matches the given filter expression
Node[] filterDom(Node[] nodes , DomFilter exp) {
    if(exp.empty) { return nodes; }
    Node[] resultNodes;
    uint hit;
    bool attribMatch;
    foreach(Node node ; nodes) {
        if(
            exp.followers
            && node.hasChildren()
            && ( exp.front.name == node.getTag() || exp.front.name == "*" )
            && exp.front.has(++hit)
        ) {
            if( exp.front.attribs.length ) {
                attribMatch = false;
                foreach(Attribute attrib ; exp.front.attribs) {
                    if( attrib.matches(node)) {
                        attribMatch = true;
                        break;
                    }
                }
                if( ! attribMatch) { continue; }
            }

            DomFilter cExp = exp;
            cExp.next;
            resultNodes ~= filterDom(node.getChildren() , cExp);
        }
        else if( !exp.followers && (exp.front.name == node.getTag() || exp.front.name == "*" ) ) {
            if( exp.front.attribs.length ) {
                foreach(Attribute attrib ; exp.front.attribs) {
                    if( attrib.matches(node) && exp.front.has(++hit)) {
                        resultNodes ~= node;
                        break;
                    }
                }
            }
            else if(exp.front.has(++hit)) {
                resultNodes ~= node;
            }
        }
    }
    return resultNodes;
}

/**
 throws the nodes away which are inside of a comment
 Returns:
  Node[]
*/
Node[] filterComments(Node[] nodes) {
    import std.algorithm.mutation : remove;
    return remove!(n => n.isComment())(nodes);
}

/**
 ditto
*/
Node[] filterComments(Dominator dom) {
    return dom.getNodes.filterComments();
}
