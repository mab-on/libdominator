module libdominator.xpath.locationpath.locationpath;

import libdominator.dom.node;
import libdominator.dom.nodetree.nodelist;
import libdominator.xpath.locationpath.axis;
import libdominator.xpath.locationpath.step;
import libdominator.xpath.nodeset;

struct LocationPath
{
	LocationStep[] steps;
}

Nodeset evaluate( Node context, LocationPath path )
{
	return evaluate([context], path);
}

Nodeset evaluate( NodeList context_nodes, LocationPath path )
{
	Nodeset result;
	evaluate(context_nodes, path, result);
	return result;
}

/**
* evaluates a XPath-LocationPath against a Node
*/
private void evaluate( NodeList context_nodes, LocationPath path, ref Nodeset output ) {
	import std.stdio;
	Nodeset stepHits;
	if( 0 < filter(context_nodes, path.steps[0], stepHits) ) {
		if( 1 == path.steps.length ) {
			output = stepHits;
		} else {
			path.steps = path.steps[1..$];
			evaluate(stepHits, path, output);
		}
	}
}
