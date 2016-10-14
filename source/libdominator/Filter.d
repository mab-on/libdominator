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

struct DomFilter {
    import std.conv : to;
    TagElement[] elements;
    size_t i;
    
    this(string[] expressions)
    {
        foreach(string expression ; expressions)
        {
            this.addExpression(expression);
        }
    }
    
    this(string expression)
    {
        this.addExpression(expression);
    }
    
    void addExpression(string expression)
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
            if( ! capt.empty) {
                auto attribs =  AttributeFilter(capt.front);
                tagElement.attribs = attribs.attribs;
            }
            this.elements ~= tagElement;
        }
    }

    
    bool popFront() {
        if( 1 + this.i < this.elements.length ) {
            this.i++;
            return true;
        }
        return false;
    }
    
    TagElement front() {
        return this.elements.length ? this.elements[this.i] : TagElement() ;
    }
    
    size_t followers() {
        return this.elements.length == 0 ? 0 : this.elements.length - 1 - this.i;
    }
    
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

struct TagElement
{
    FilterPicktype picktype;
    ushort[] picks;
    string name;
    Attribute[] attribs;
    
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
struct AttributeFilter {
    import std.array : split;
    Attribute[] attribs;
    
    this(string expression)
    {
        if (expression.length)
        {
            foreach (mAttrib; matchAll(expression, rAttribExpression))
            {
                string key = chompPrefix(chomp(strip(mAttrib[1]), "\"'"), "\"'");
                string[] values;
                foreach (v; split(mAttrib[2]))
                {
                    values ~= chompPrefix(chomp(strip(v), "\"'"), "\"'");
                }
                this.attribs ~= Attribute(key, values);
            }
        }
    }
    
    unittest {
        AttributeFilter attribFilter;

        attribFilter = AttributeFilter("class:myClass,id:myID");
        assert(attribFilter.attribs == [Attribute("class", ["myClass"]), Attribute("id", ["myID"])]);
        
        attribFilter = AttributeFilter("class:myClass");
        assert(attribFilter.attribs == [Attribute("class", ["myClass"])]);

        attribFilter = AttributeFilter("data-url:http://www.mab-on.net/");
        assert(attribFilter.attribs == [Attribute("data-url", ["http://www.mab-on.net/"])]);
    }
}

Node[] filterDom(Dominator dom , DomFilter expressions) {
    return filterDom(dom,[expressions]);
}
Node[] filterDom(Dominator dom , DomFilter[] expressions) {
    return dom.getNodes().filterDom(expressions);
}

Node[] filterDom(Node[] nodes , DomFilter[] expressions) {
    if(expressions.length == 0) {return nodes;}
    Node[] resultNodes;
    foreach(DomFilter exp ; expressions) {
       resultNodes ~= filterDom(nodes , exp);
    }
    return resultNodes;
}

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
            cExp.popFront;
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
 
 Node[] filterAttribute(Node[] nodes, Attribute[] attribs)
{
    if (attribs.length == 0) {return nodes;}
    
    Node[] resultNodes;
    foreach (Node node; nodes)
    {
        ubyte hitCount;
        foreach (Attribute attrib; attribs)
        {
            if (attrib.matches(node))
            {
                if(hitCount+1 == attribs.length) 
                {
                    resultNodes ~= node;
                }
                else {
                    hitCount++;
                }
            }
        }

    }
    return resultNodes;
}

/**
 throws the Nodes away which are inside of a comment
 Returns:
  Node[]
*/
Node[] filterComments(Node[] nodes) {
    Node[] resultNodes;
    foreach(node ; nodes) {
        if(!node.isComment()) { 
            resultNodes ~= node;
        }
    }
    return resultNodes;
}

/**
 ditto
*/
Node[] filterComments(Dominator dom) {
    return dom.getNodes.filterComments();
}
