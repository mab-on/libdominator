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

class InUseAttributeError : DOMException {
	this() { super( "The attribute is in use."  , 10 ); }
}

/// https://heycam.github.io/webidl/#notfounderror
class NotFoundError : DOMException {
	this() { super( "The object can not be found here."  , 8 ); }
}