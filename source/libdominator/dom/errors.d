module libdominator.dom.errors;

class DOMException : Exception
{
	import std.format : format;
	this(string descrition, size_t err_code) {
        super( "%s(%s)".format(descrition , err_code));
    }
}

class InvalidModificationError : DOMException
{
	this() { super( "The object can not be modified in this way."  , 13 ); }
}
