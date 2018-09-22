# libdominator

## What is this about?

A library, containing the following packages:

- `DOM` - Document Object Model
- `XML/HTML Parser` - read XML/HTML into a manageable structure (DOM)
- `xPath` - filtering the dom

## Example
```D
import libdominator;

Node doc =
	`<root>
		<tag_a>
			<p>preceding A</p>
			<p>preceding B</p>
		</tag_a>
		<tag key=value fasel ding=dang\ dong >
			<sub>ding</sub>
			<sub foo=dang>dang</sub>
			<sub foo="doing">doing</sub>
			text
		</tag>
		<tag_b>
			<p>following A</p>
			<p>following B</p>
		</tag_b>
	</root>`.parse;

	//setup filter
	LocationPath xPath;
	xPath.steps ~= LocationStep( Axis.child , new Element("tag") );
	xPath.steps ~= LocationStep( Axis.child , new Element("sub") );
	xPath.steps ~= LocationStep( Axis.following , new Element("p") );

	Node[] hits = xPath.evaluate(doc);

	assert( hits[0].outerHTML == "<p>following A</p>");
	assert( hits[1].outerHTML == "<p>following B</p>");
```
