/**
 * Copyright:
 * (C) 2016 Martin Brzenska
 *
 * License:
 * Distributed under the terms of the MIT license.
 * Consult the provided LICENSE.md file for details
 */
module libdominator.Node;

import std.string : toLower;
import std.format : format ;
import std.conv : to ;

import libdominator;

version(unittest) {
    import libdominator.Filter;
    import std.file;
}

///Represents a node in a DOM
class Node {
  private string tag;
  private Attribute[] arrAttributes;
  private uint startPos, endPos;
  private ushort startTagLength, endTagLength;
  private bool is_comment;
  private Node* parent;
  private Node*[] children;

  ///Makes a naked node object
  this() {}

  ///Makes a node with a given tagname
  this(string tag) {
    this.setTag(tag);
  }

  ///Makes a node with a given tagname and with the information for the position in the Document
  this(T)(string tag, T startPosition) {
    this.setTag(tag);
    this.setStartPosition(startPosition);
  }

  ///Sets the tagname
  public Node setTag(string tag) {
    this.tag = toLower(tag);
    return this;
  }

  ///Sets the position in the document where this node begins
  public Node setStartPosition(T)(T position) {
    this.startPos = to!uint(position);
    return this;
  }

  ///Sets the position in the document where this node ends
  public Node setEndPosition(T)(T position) {
    this.endPos = to!uint(position);
    return this;
  }

  ///Does what the name says
  public string getTag() {
    return this.tag;
  }
  /// ditto
  public Attribute[] getAttributes() {
    return this.arrAttributes;
  }

  /// ditto
  public void addAttribute(Attribute attribute) {
    this.arrAttributes ~= attribute;
  }

  /// ditto
  public uint getStartPosition() {
    return this.startPos;
  }

  /// ditto
  public uint getEndPosition() {
    return this.endPos;
  }

  /// ditto
  public Node setStartTagLength(T)(T length) {
    this.startTagLength = to!ushort(length);
    return this;
  }

  /// ditto
  public Node setEndTagLength(T)(T length) {
    this.endTagLength = to!ushort(length);
    return this;
  }

  /// ditto
  public ushort getStartTagLength() {
    return this.startTagLength;
  }

  /// ditto
  public ushort getEndTagLength() {
    return this.endTagLength;
  }
  unittest {
    const string content = `<ol id="ol-1">
          <li id="li-1-ol-1">list Inner</li>
          <li id="li-2-ol-1">list Inner</li >
          <li id="li-3-ol-1"> list Inner < /li>
          <li id="li-4-ol-1"> list Inner < /li >
        </ol>`;
      Dominator dom = new Dominator(content);
      Node[] liNodes = dom.filterDom(DomFilter("li"));
      assert(liNodes[0].getEndTagLength == 5 );
      assert(liNodes[1].getEndTagLength == 6 , to!(string)(liNodes[1].getEndTagLength));
      assert(liNodes[2].getEndTagLength == 6 );
      assert(liNodes[3].getEndTagLength == 7 );
  }

  ///Markes this node to be inside of a comment
  public Node isComment(bool sw) {
    this.is_comment = sw;
    return this;
  }

  /**
  * Returns: true if the node is marked to be inside of a comment, otherwise false.
  */
  public bool isComment() {
    return this.is_comment;
  }

  ///Sets the given node as the parent node
  public void setParent(Node* pNode) {
    this.parent = pNode;
  }

  ///Does what the name says
  public Node getParent() {
    return this.parent is null ? new Node : (*this.parent);
  }

  ///Adds a node as a child node
  public void addChild(Node* pNode) {
    this.children ~= pNode;
  }

  ///Does what the name says
  public Node[] getChildren() {
    Node[] nodes;
    foreach(Node* pNode ; this.children) {
      if(pNode !is  null) { nodes ~= (*pNode); }
    }
    return nodes;
  }

  /**
  * Returns: true if the node has children nodes.
  */
  public size_t hasChildren() {
    return this.children.length;
  }

  /**
  * Does what the name says
  */
  public Node[] getSiblings() {
    import std.algorithm.mutation : remove;
    return remove!(a => a.getStartPosition() == this.getStartPosition())(this.getParent().getChildren());
  }

  /**
  * Returns: true if the node has a parent node.
  */
  public bool hasParent() {
    return (parent !is null);
  }

  private void collectDescendants(Node node , ref Node[] nodes) {
    foreach(Node childNode ; node.getChildren()) {
      nodes ~= childNode;
      collectDescendants(childNode , nodes);
    }
  }

  public Node[] getDescendants() {
    Node[] nodes;
    collectDescendants(this , nodes);
    return nodes;
  }

  private void collectAncestors(Node node , ref Node[] nodes) {
    if(node.hasParent) {
      Node parentNode = node.getParent();
      nodes ~= parentNode;
      collectAncestors(parentNode , nodes);
    }
  }

  public Node[] getAncestors() {
    Node[] nodes;
    collectAncestors(this , nodes);
    return nodes;
  }
  unittest {
    Node
      root = new Node("root"),
      firstChild = new Node("first-child"),
      secondChild = new Node("second-child");

      firstChild.setParent(&root);
      secondChild.setParent(&firstChild);

      assert(secondChild.getAncestors.length == 2);

  }
}
