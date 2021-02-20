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

class SyntaxError : DOMException {
	this() { super( "The string did not match the expected pattern."  , 12 ); }
}

class InvalidCharacterError : DOMException {
	this() { super( "The string contains invalid characters." , 5 ); }
}

class NamespaceError : DOMException {
	this() { super( "The operation is not allowed by Namespaces in XML." , 14 ); }
}