module libdominator.dom.characterdata.comment;

import libdominator.dom.characterdata.characterdata;

class Comment : CharacterData
{
  this(string value="")
  {
    super("#comment" , value);
  }

  override public ushort nodeType()
  { return 8; }

  override public string outerHTML()
  {
    import std.algorithm : map;
    import std.array : join , array;

    return
    "<!--" ~ this.value ~ "-->";
  }
}