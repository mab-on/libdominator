module libdominator.xpath.locationpath.axis.filter;

import libdominator.dom.node;
import libdominator.dom.nodetree.nodelist;
import libdominator.xpath.locationpath.axis;
import libdominator.xpath.nodeset;

size_t filter(NodeList context_nodes, Axis axis  , out Nodeset output ) {
	foreach(Node context_node ; context_nodes) {
		if(context_node is null) {
			continue;
		}
		final switch(axis)
		{
			case Axis.self:
				output ~= context_node;
				break;

			case Axis.child:
				foreach(child ; context_node.childNodes())
				{
					output ~= child;
				}
				break;

			case Axis.ancestor_or_self:
				output ~= context_node;
				goto case Axis.ancestor;

			case Axis.ancestor:
				foreach( ancestor ; context_node.getAncestors() )
				{
					output ~= ancestor;
				}
				break;

			case Axis.descendant_or_self:
				output ~= context_node;
				goto case Axis.descendant;

			case Axis.descendant:
				foreach( descendant ; context_node.getDescendants() )
				{
					output ~= descendant;
				}
				break;


			case Axis.following_sibling:
				bool isFollowing = false;
				foreach( sibling ; context_node.getSiblings() )
				{
					if( isFollowing )
					{
						output ~= sibling;
					}
					else if( sibling is context_node )
					{
						isFollowing = true;
					}
				}
				break;

			case Axis.preceding_sibling:
				foreach( sibling ; context_node.getSiblings() )
				{
					if( sibling is context_node )
					{
						break;
					}
					else
					{
						output ~= sibling;
					}
				}
				break;

			case Axis.parent:
				if(context_node.hasParent())
				{
					output ~= context_node.parentNode;
				}
				break;

			/**
			* the preceding axis contains all nodes in the same document as the context node
			* that are before the context node in document order,
			* excluding any ancestors and excluding attribute nodes and namespace nodes
			*/
			case Axis.preceding:
				if( ! context_node.hasParent()) {
					break;
				}
				foreach( parent_sibling ; context_node.parentNode.getSiblings() ) {
					if( parent_sibling is context_node.parentNode ) {
						break;
					}
					foreach( preceding ; parent_sibling.getDescendants() ) {
						output ~= preceding;
					}
				}

				break;

			case Axis.following:
				if( ! context_node.hasParent()) {
					break;
				}
				bool isFollowing = false;
				foreach( parent_sibling ; context_node.parentNode.getSiblings() ) {
					if( isFollowing ) {
						foreach( following ; parent_sibling.getDescendants() ) {
							output ~= following;
						}
					}
					else if( parent_sibling is context_node.parentNode ) {
						isFollowing = true;
					}
				}
				break;

			//TODO
			case Axis.attribute:
			case Axis.namespace:
				break;
		}
	}

	return output.length;
}
