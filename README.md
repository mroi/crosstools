Cross-Compiler for macOS
========================

Simply run `make` to build macOS-hosted cross-compilation toolchains targeting
* Linux/i386,
* Linux/x86_64, and
* Windows/i386.

Runtime libraries are taken from [Ubuntu](http://packages.ubuntu.com) and 
[Mingw-w64](http://mingw-w64.org/). The build system will tell you, which sources you need 
to download and unpack.

Note that the entire build runs 
[sandboxed](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man7/sandbox.7.html) 
to bar it from polluting your system. Keep this in mind when something fails.

This work is licensed under the [WTFPL](http://www.wtfpl.net/), so you can do anything you 
want with it.
