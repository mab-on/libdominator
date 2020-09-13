module libdominator.dom.characterdata.text;

import libdominator.dom.characterdata.characterdata;

class Text : CharacterData
{
  this(string value="")
  {
    super("#text" , value);
  }

  override public ushort nodeType()
  { return 3; }

}
