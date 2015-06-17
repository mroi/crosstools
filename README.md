Cross-Compiler for OS X
=======================

Simply run `make` to build OS-X-hosted cross-compilation toolchains targeting
* Linux/i386,
* Linux/x86_64, and
* Windows/i386.
Runtime libraries are taken from [Ubuntu](http://packages.ubuntu.com) and 
[MinGW](http://www.mingw.org). The build system will tell you, which sources you need to 
download and unpack.

Note that the entire build runs 
[sandboxed](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man7/sandbox.7.html) 
to bar it from polluting your system. Keep this in mind when something fails.
