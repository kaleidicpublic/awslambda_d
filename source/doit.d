import std.stdio;

void main(string[] args)
{
	writefln("Hello world!");
	foreach(arg;args)
		writefln("you gave me: %s",arg);
	writefln("==");
	writefln("bye");
}
