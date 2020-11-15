module libdominator.dom.characterdata.comment;

import libdominator.dom.node.attribute;
import libdominator.dom.characterdata.characterdata;
import libdominator.dom.node.node;

class Comment : CharacterData
{
  this(string value="")
  {
    super("#comment" , value);
  }

  override public ushort nodeType()
  { return Node.COMMENT_NODE; }

  override public string toString()
  {
    import std.algorithm : map;
    import std.array : join , array;

    return
    "<!--" ~ this.value ~ "-->";
  }
}
