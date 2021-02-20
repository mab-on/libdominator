module libdominator.dom.parser.parser;

import std.stdio, std.typecons;
import libdominator.dom.node;
import libdominator.dom.characterdata;

alias TryElemRes = Tuple!(size_t, "needle", Element, "element");

public Document parse(string haystack)
{
		import std.algorithm.searching : canFind;
        import std.uni : icmp;
        import std.ascii : isWhite , isAlphaNum , isAlpha;
        import std.container.slist;
        import std.string : strip;

		Document document = new Document();
        if(haystack.length == 0) { return document; }

		auto nodestack = SList!Node();
		auto empty_elements = SList!Node();

        size_t needleProbe;
        enum ParserStates : ubyte {
            inElementOpener = 1,
            inComment = 2,
            inTextNode = 4
        }
        ubyte state;
        size_t needle;

		string _name;
		string _text;

        //skip whitespaces
        while(needle < haystack.length && haystack[needle].isWhite) { needle++; }
        if(needle >= haystack.length) { return document; } //EOF

        DocumentType doctype;
        needleProbe = tryDoctype(needle, haystack, doctype);
        if( needleProbe ) {
            document.doctype = doctype;
            needle = needleProbe;
        }

        do {
            if(haystack[needle] == '<') {

                needleProbe = tryElementTerminator(_name , haystack , needle);
                if( needleProbe )
                {
					needle = needleProbe;
                	if(_name != nodestack.front().nodeName())
                	{
                		if( canFind!( (Node a , string b) => 0 == icmp(a.nodeName(), b) )(nodestack[] , _name) )
                		{
							while( icmp(_name, nodestack.front().nodeName()) != 0 &&  !nodestack.empty )
							{
								Element non_closing = cast(Element)nodestack.front();
								non_closing.empty_element = true;

								nodestack.removeFront();
								nodestack.front.appendChild( non_closing );

								foreach(orphan ; non_closing.childNodes())
								{
									nodestack.front.appendChild( orphan );
								}
							}
                		}
                		else
                		{
                			//closing tags with no opener are garbage and can be skipped
                			continue;
                		}
                	}

					Node child = nodestack.front();
					if( ! nodestack.empty)
					{
						nodestack.removeFront();
					}

					if( ! nodestack.empty)
					{
						nodestack.front().appendChild(child);
					}

                    continue;
                }

                needleProbe = tryComment(haystack , needle);
                if( needleProbe )
                {
                	nodestack.front.appendChild( new Comment( haystack[4+needle..needleProbe-3] ) );
                    needle = needleProbe;
                    continue;
                }

                TryElemRes eRes = tryElementOpener(needle, haystack);
                if( eRes.needle )
                {
                    eRes.element.ownerDocument = document;
                    if(document.documentElement is null)
                    {
                        document.documentElement = eRes.element;
                    }
                    nodestack.insert(eRes.element);

                    needle = eRes.needle;
                    if(state & ParserStates.inComment) { /*hmmmm...? */ }

                    continue;
                }

            }

        	needleProbe = tryText(needle , haystack , _text);
			if( !nodestack.empty && _text.length )
			{
				needle = needleProbe;
				nodestack.front().appendChild(new Text( _text ));
				continue;
			}

			/*
			* if no try*-Function above matched, advance the needle
			*/
            needle++;
        } while(needle < haystack.length);

	return document;
}

private size_t tryDoctype(size_t needle, ref string haystack, DocumentType doctype) {
    import std.uni : sicmp;
    import std.ascii : isWhite , isAlphaNum;
    size_t iNeedle;

    if( 9+needle < haystack.length && 0 == sicmp(haystack[needle..9+needle], "<!DOCTYPE") ) {
        needle += 9;

        //skip whitespaces
        while(needle < haystack.length && haystack[needle].isWhite) { needle++; }
        if(needle >= haystack.length) { return 0; } //EOF


        //The name is AlphaNumeric
        iNeedle = needle;
        while(needle < haystack.length && haystack[needle].isAlphaNum) { needle++; }
        if(needle >= haystack.length) { return 0; } //EOF

        doctype = new DocumentType(haystack[ iNeedle..needle ], "", "");

        while(needle < haystack.length) {
            if(haystack[needle] == '<') return 0;
            if(haystack[needle] == '>') return 1+needle;
            needle++;
        }
        if(needle >= haystack.length) { return 0; } //EOF
    }

    return 0;
}

private size_t tryText(size_t needle , ref string haystack , out string text)
{
	import std.string : strip;

	size_t startCoord = needle;
	while(needle < haystack.length && haystack[needle] != '<')
	{
		needle++;
	}

	text = (needle >= haystack.length)
	? haystack[startCoord..needle-1].strip //EOF
	: haystack[startCoord..needle].strip;

	return needle;
}

private TryElemRes tryElementOpener(size_t needle, ref string haystack)
{
    import std.ascii : isWhite , isAlphaNum , isAlpha;
    enum ParserStates : ubyte {
        name = 1,
        key = 2,
        value = 4,
        err = 8,
        ready = 16
    }
    ubyte state = 0;
    string name;
    char inQuote = 0x00;
    size_t nameCoord;
    size_t[2] keyCoord, valCoord;

    if(haystack[needle] != '<') {
        return TryElemRes(0, null);
    }

    needle++;

    /*
    * parse the elements name
    */
    //first, skip whitespaces
    while(needle < haystack.length && haystack[needle].isWhite) { needle++; }
    if(needle >= haystack.length) { 
         //EOF
        return TryElemRes(0, null); 
    }

    //The name begins with a underscore or a alphabetical character.
    if(
        ! haystack[needle].isAlpha
        && ! haystack[needle] == '_'
    ) {
        return TryElemRes(0, null);
    }
    nameCoord = needle;

    //The name contains letters, digits, hyphens, underscores, and periods
    for(; needle < haystack.length && !haystack[needle].isWhite ; ++needle) {
        if(
            ! haystack[needle].isAlphaNum
            &&  haystack[needle] != '-'
            &&  haystack[needle] != '_'
            &&  haystack[needle] != '.'
            &&  haystack[needle] != ':'
        ) {
            if(haystack[needle] == '>') {
                state |= ParserStates.ready;
                break;
            } else {
                return TryElemRes(0, null);
            }
        }
    }
    if(needle >= haystack.length) { 
        return TryElemRes(0, null);
    } //EOF

    name = haystack[nameCoord..needle];
    state |= ParserStates.name;
    auto element = new Element(name);

    /*
    * Parse attributes
    */
    while( ! (state & ParserStates.ready))
    {
        //reset state
        state &= ~(ParserStates.key | ParserStates.value);

        //Check if the next non-whitespace char finishes our job here
        while(needle < haystack.length && haystack[needle].isWhite){ needle++; }
        if(needle >= haystack.length) {
            //EOF
            return TryElemRes(0, null); 
        }
        if(haystack[needle] == '>')
        {
            state |= ParserStates.ready;
            return TryElemRes(1+needle, element);
        }

        /*
        * Find the attr-key
        */
        keyCoord[0] = needle;
        for(; needle < haystack.length && !haystack[needle].isWhite ; ++needle)
        {
            if(haystack[needle] == '>') {
                state |= ParserStates.ready;
                break;
            }
            if(haystack[needle] == '=') {
                break;
            }
        }
        if(needle >= haystack.length) { 
            //EOF
            return TryElemRes(0, null); 
        } 
        keyCoord[1] = needle;

        if(state & ParserStates.ready) {
            auto attr = new Attr(haystack[keyCoord[0]..keyCoord[1]] , "" , inQuote );
            element.setAttributeNode(attr);
        }
        else
        {
            /**
            * Parse attribute value if exist
            */

            //skip whitespaces
            while(needle < haystack.length && haystack[needle].isWhite) { needle++; }
            if(needle >= haystack.length) { 
                //EOF
                return TryElemRes(0, null); 
            }

            if(haystack[needle] == '>') {
                //there is no value and this is the end
                state |= ParserStates.ready;
                auto attr = new Attr(haystack[keyCoord[0]..keyCoord[1]] , "" , inQuote );
                element.setAttributeNode(attr);
                return TryElemRes(1+needle, element);
            }
            else if(haystack[needle] == '=')
            {
                //here comes the value...
                needle++;
                while(needle < haystack.length && haystack[needle].isWhite) { needle++; }
                if(needle >= haystack.length) { 
                    return TryElemRes(0, null); 
                } //EOF

                if(haystack[needle] == '"' || haystack[needle] == '\'' ) {
                    //quoted value
                    inQuote = haystack[needle];
                    needle++;
                    valCoord[0] = needle;
                    while(
                        needle < haystack.length
                        && (haystack[needle] != inQuote
                        || ( haystack[needle] == inQuote && haystack[needle-1] == '\\'))
                    ) {
                        needle++;
                    }
                    valCoord[1] = needle;
                    needle++;
                }
                else //not quoted value
                {
                    inQuote = 0x00;
                    valCoord[0] = needle;
                    while(
                        needle < haystack.length
                        && (
                            !haystack[needle].isWhite
                            || ( haystack[needle].isWhite && haystack[needle-1] == '\\')
                        )
                    ) {
                        if(haystack[needle] == '>')
                        {
                            state |= ParserStates.ready;
                            break;
                        }
                        needle++;
                    }
                    valCoord[1] = needle;
                }
            }
            else //there is no value
            {
                valCoord = valCoord.init;
            }
            if(keyCoord[1] >= haystack.length || valCoord[1] >= haystack.length) {
                return TryElemRes(0, null);
            }
            auto attr = new Attr(
                haystack[keyCoord[0]..keyCoord[1]],
                haystack[valCoord[0]..valCoord[1]],
                inQuote
            );
            element.setAttributeNode(attr);
        }
    }
    return TryElemRes(1+needle, element);
}

private size_t tryElementTerminator(out string name , ref string haystack , size_t needle) {
    import std.ascii : isWhite;
    if( haystack[needle] != '<' ) {return 0;}

    size_t[2] nameCoord;
    size_t position = needle;

    for(needle = needle + 1; needle < haystack.length && haystack[needle].isWhite ; needle++) {}
   	if(needle >= haystack.length) { return 0; } //EOF
    if(haystack[needle] != '/') { return 0; }
    nameCoord[0] = 1 + needle;
    for(
        needle = needle + 1 ;
        needle < haystack.length
        && !haystack[needle].isWhite ;
        needle++
    ) {
        if(haystack[needle] == '>') {
            name = haystack[nameCoord[0]..needle];
            needle++;
            return needle;
        }
    }
    nameCoord[1] = needle;
    for(; needle < haystack.length && haystack[needle].isWhite ; needle++) {}
    if(haystack[needle] == '>') {
        name = haystack[nameCoord[0]..nameCoord[1]];
        needle++;
        return needle;
    }
    return 0;
}

private size_t tryComment(ref string haystack , size_t needle) {
    if(
        needle + 4 < haystack.length
        && haystack[needle..needle+4] == "<!--"
    )
    { needle = needle+4; }
	else
	{ return 0; }

	while(needle < haystack.length && haystack[needle] != '-')
	{ needle++; }

	if(haystack[needle] != '-')
	{ return 0; } //EOF

	if(
		needle + 3 < haystack.length
		&& haystack[needle..needle+3] == "-->"
	)
	{ return 3+needle; }

	return 0;
}
