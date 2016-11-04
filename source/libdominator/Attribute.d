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

///Struct for Node Attributes
struct Attribute
{
    string key;
    string[] values;

    /**
    * Params:
    * key = the Name of the Attribute (can be prefixed with '(regex)')
    * values = a whitespace serparated List of Attribute Values (each Value can be prefixed with '(regex)')
    */
    this(string key, string values)
    {
        import std.string : toLower;
        this.key = toLower(key);
        this.values = split(values);
    }
    /**
    * Params:
    * key = The name of the attribute (can be prefixed with '(regex)')
    * values = Array of attribute values (each value can be prefixed with '(regex)')
    */
    this(string key, string[] values)
    {
        this.key = key;
        this.values = values;
    }

    ///Checks if the given node matches the attributes given key
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
    ///Checks if at least one of the attribute values of the given node matches the given attribute values
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

    /**
    * Checks if the given node matches key and values of this attribute.
    * Note that all atribute values from this attribute must match the given nodes attribute values - not the other way round
    */
    bool matches(Node node)
    {
        return this.matchesKey(node) && this.matchesValue(node);
    }

}
