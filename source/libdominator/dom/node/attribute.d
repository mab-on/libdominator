module libdominator.dom.node.attribute;

struct Attribute
{
	string _prefix;
	string _localName;
	string _value;
	char _wrapper;

  this(string name, string value , char wrapper='"' )
  {
  	this.name = name;
  	this.value = value;
  	this._wrapper = wrapper;
  }

	@property string name()
	{
		return this._prefix.length ? this._prefix ~ ":" ~ this._localName : this._localName;
	}

	@property void name(string name) {
		import std.algorithm.searching : findSplit;
		if(auto result = name.findSplit(":"))
		{
			this._prefix = result[0];
			this._localName = result[2];
		}
		else
		{
			this._prefix = "";
			this._localName = name;
		}
	}

	string localName() { return this._localName; }

	string prefix() { return this._prefix; }

	@property string value() { return this._value; }
	@property void value(string value) { this._value = value; }

  string toString()
  {

  	string escape(string value , char wrapper)
  	{
  		if(wrapper == 0x00) return value;

  		string escaped;
  		for(size_t i; i<value.length; i++)
  		{
  			if(value[i] == wrapper)
  			{
  				if(i == 0) { escaped = '\\'  ~ value[0..i]; }

  				else if(value[i-1] != '\\')
  				{
  					if(escaped.length) { escaped ~= "\\" ~ value[i]; }
  					else
  						{ escaped = value[0..i] ~ '\\'  ~ value[i]; }
  				}
  			}
  			else if(escaped.length) { escaped ~= value[i]; }
  		}
  		return wrapper ~ (escaped.length ? escaped : value) ~ wrapper;
  	}

  	return this.name
  	~ ( this.value.length
  		? "=" ~ escape(this.value , this._wrapper)
  		: ""
  		);
  }
  unittest
  {
  	assert( Attribute("key" , "value" , '"').toString == `key="value"` );
  	assert( Attribute("key" , "value" , 0x00).toString == `key=value` );
  	assert(
  		Attribute("key" , `value with "doublequotes" and 'singlequotes'` , '"').toString
  		==
  		`key="value with \"doublequotes\" and 'singlequotes'"`
  		);
  	assert(
  		Attribute("key" , `value with "doublequotes" and 'singlequotes'` , '\'').toString
  		==
  		`key='value with "doublequotes" and \'singlequotes\''`
  		);
  	assert(
  		Attribute("key" , `value with \"doublequotes\" , "doublequotes" and 'singlequotes'` , '"').toString
  		==
  		`key="value with \"doublequotes\" , \"doublequotes\" and 'singlequotes'"`
  		);
  }

}