Here are some examples of location paths using the unabbreviated syntax and the abbreviated syntax
The Examples are taken from https://www.w3.org/TR/1999/REC-xpath-19991116/#location-paths
The Format for the list is:

? desctiption  
F `unabbreviated syntax`  
A `abbreviated syntax`  
______________________

? selects the para element children of the context node  
F `child::para`  
A `para`  

? selects all element children of the context node  
F ``child::*``  
A `*`  

? selects all text node children of the context node  
F ``child::text()``  
A `text()`  

? selects all the children of the context node, whatever their node type  
F ``child::node()``  
A

? selects the name attribute of the context node  
F `attribute::name`  
A `@name`  

? selects all the attributes of the context node  
F `attribute::*`  
A `@*`  


? selects the para element descendants of the context node  
F `descendant::para`  
A `.//para`  

? selects all div ancestors of the context node  
F `ancestor::div`  
A

? selects the div ancestors of the context node and, if the context node is a div element, the context node as well  
F `ancestor-or-self::div`  
A

? selects the para element descendants of the context node and, if the context node is a para element, the context node as well  
F `descendant-or-self::para`  
A

? selects the context node if it is a para element, and otherwise selects nothing  
F `self::para`  
A

? selects the para element descendants of the chapter element children of the context node  
F `child::chapter/descendant::para`  
A `chapter//para`  

? selects all para grandchildren of the context node  
F `child::*/child::para`  
A `*/para`  

? selects the document root (which is always the parent of the document element)  
F `/`  
A

? selects all the para elements in the same document as the context node  
F `/descendant::para`  
A

? selects all the item elements that have an olist parent and that are in the same document as the context node  
F `/descendant::olist/child::item`  
A

? selects the first para child of the context node  
F `child::para[position()=1]`  
A `para[1]`  

? selects the last para child of the context node  
F `child::para[position()=last()]`  
A `para[last()]`  

? selects the last but one para child of the context node  
F `child::para[position()=last()-1]`  
A

? selects all the para children of the context node other than the first para child of the context node  
F `child::para[position()>1]`  
A

? selects the next chapter sibling of the context node  
F `following-sibling::chapter[position()=1]`  
A

? selects the previous chapter sibling of the context node  
F `preceding-sibling::chapter[position()=1]`  
A

? selects the forty-second figure element in the document  
F `/descendant::figure[position()=42]`  
A

? selects the second section of the fifth chapter of the doc document element  
F `/child::doc/child::chapter[position()=5]/child::section[position()=2]`  
A

? selects all para children of the context node that have a type attribute with value warning  
F `child::para[attribute::type="warning"]`  
A `para[@type="warning"]`  

? selects the fifth para child of the context node that has a type attribute with value warning  
F `child::para[attribute::type='warning'][position()=5]`  
A `para[@type="warning"][5]`  

? selects the fifth para child of the context node if that child has a type attribute with value warning  
F `child::para[position()=5][attribute::type="warning"]`  
A `para[5][@type="warning"]`  

? selects the chapter children of the context node that have one or more title children with string-value equal to Introduction  
F `child::chapter[child::title='Introduction']`  
A `chapter[title="Introduction"]`  

? selects the chapter children of the context node that have one or more title children  
F `child::chapter[child::title]`  
A `chapter[title]`  

? selects the chapter and appendix children of the context node  
F `child::*[self::chapter or self::appendix]`  
A

? selects the last chapter or appendix child of the context node  
F `child::*[self::chapter or self::appendix][position()=last()]`  
A

? selects the last para child of the context node  
F
A `para[last()]`  


? selects the second section of the fifth chapter of the doc  
F
A `/doc/chapter[5]/section[2]`  


? selects all the para descendants of the document root and thus selects all para elements in the same document as the context node  
F
A `//para`  

? selects all the item elements in the same document as the context node that have an olist parent  
F
A `//olist/item`  

? selects the context node  
F
A `.`  


? selects the parent of the context node  
F
A `..`  

? selects the lang attribute of the parent of the context node  
F
A `../@lang`  











employee[@secretary and @assistant] selects all the employee children of the context node that have both a secretary attribute and an assistant attribute
