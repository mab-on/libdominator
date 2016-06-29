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

class Node {
  private string tag;
  private Attribute[] arrAttributes;
  private uint startPos, endPos;
  private ushort startTagLength, endTagLength;
  private bool is_comment;
  private Node* parent;
  private Node*[] children;

  this() {}

  this(string tag) {
    this.setTag(tag);
  }

  this(T)(string tag, T startPosition) {
    this.setTag(tag);
    this.setStartPosition(startPosition);
  }

  public Node setTag(string tag) {
    this.tag = toLower(tag);
    return this;
  }

  public Node setStartPosition(T)(T position) {
    this.startPos = to!uint(position);
    return this;
  }

  public Node setEndPosition(T)(T position) {
    this.endPos = to!uint(position);
    return this;
  }

  public string getTag() {
    return this.tag;
  }

  public Attribute[] getAttributes() {
    return this.arrAttributes;
  }

  public void addAttribute(Attribute attribute) {
    this.arrAttributes ~= attribute;
  }

  public uint getStartPosition() {
    return this.startPos;
  }

  public uint getEndPosition() {
    return this.endPos;
  }

  public Node setStartTagLength(T)(T length) {
    this.startTagLength = to!ushort(length);
    return this;
  }

  public Node setEndTagLength(T)(T length) {
    this.endTagLength = to!ushort(length);
    return this;
  }

  public ushort getStartTagLength() {
    return this.startTagLength;
  }

  public ushort getEndTagLength() {
    return this.endTagLength;
  }

  public Node isComment(bool sw) {
    this.is_comment = sw;
    return this;
  }

  public bool isComment() {
    return this.is_comment;
  }
  
  public void setParent(Node* pNode) {
    this.parent = pNode;
  }
  
  public Node getParent() {
    return this.parent is null ? new Node : (*this.parent);
  }
  
  public void addChild(Node* pNode) {
    this.children ~= pNode;
  }
  
  public Node[] getChildren() {
    Node[] nodes;
    foreach(Node* pNode ; this.children) {
      if(pNode !is  null) { nodes ~= (*pNode); }
    }
    return nodes;
  }
  
  public size_t hasChildren() {
    return this.children.length;
  }
  
  public bool hasParent() {
    return (parent !is null);
  }
  
}
