/**
 * Copyright:
 * (C) 2016 Martin Brzenska
 *
 * License: 
 * Distributed under the terms of the MIT license. 
 * Consult the provided LICENSE.md file for details
 */
module libdominator.Attribute;

import std.regex : regex , matchFirst ;
import std.array : split;

import libdominator;

struct Attribute
{
    string key;
    string[] values;

    this(string key, string values)
    {
        this.key = key;
        this.values = split(values);
    }

    this(string key, string[] values)
    {
        this.key = key;
        this.values = values;
    }

    bool matchesKey(Node node)
    {
        if (key.length > 6 && key[0..7] == "(regex)")
        {
            auto regx = regex(key[7..$]);
            foreach (Attribute attrib; node.getAttributes())
            {
                auto capture = matchFirst(attrib.key, regx);
                if (!capture.empty)
                {
                    return true;
                }
            }
        }
        else
        {
            foreach (Attribute attrib; node.getAttributes())
            {
                if (attrib.key == key)
                {
                    return true;
                }
            }
        }
        return false;
    }

    bool matchesValue(Node node)
    {
        if (values.length == 0)
        {
            return true;
        }
        ubyte hitCount;
        foreach (string value; values)
        {
            bool isRegex;
            if (value.length > 6 && value[0 .. 7] == "(regex)")
            {
                isRegex =true;
            }
            foreach (Attribute attrib; node.getAttributes())
            {
                foreach (string nodeValue; attrib.values)
                {
                    if(isRegex)
                    {
                        auto capture = matchFirst(nodeValue, regex(value[7..$]));
                        if (!capture.empty) { hitCount++; }
                    }
                    else {
                        if (nodeValue == value) { hitCount++; }
                    }
                    if(hitCount == values.length) { return true; }
                }
            }   
        }
        return false;
    }

    bool matches(Node node)
    {
        return this.matchesKey(node) && this.matchesValue(node);
    }

}

