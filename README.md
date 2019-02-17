*This project is no longer actively maintained.*
*I recommend installing a cross compiler using the [Nix](https://nixos.org) package manager:*

```nix
let
	linux32 = import <nixpkgs> { crossSystem = { config = "i686-linux"; }; };
	linux64 = import <nixpkgs> { crossSystem = { config = "x86_64-linux"; }; };
	win32 = import <nixpkgs> { crossSystem = { config = "i686-pc-mingw32"; libc = "msvcrt"; }; };
	win64 = import <nixpkgs> { crossSystem = { config = "x86_64-pc-mingw32"; libc = "msvcrt"; }; };
in (import <nixpkgs> {}).mkShell {
	buildInputs = [
		linux32.buildPackages.gcc
		linux64.buildPackages.gcc
		win32.buildPackages.gcc
		win64.buildPackages.gcc
	];
}
```

Cross-Compiler for macOS
========================

Simply run `make` to build macOS-hosted cross-compilation toolchains targeting
* Linux/i386,
* Linux/x86_64
* Windows/i386, and
* Windows/x86_64.

Runtime libraries are taken from [Ubuntu](http://packages.ubuntu.com) and 
[Mingw-w64](http://mingw-w64.org/). The build system will tell you, which sources you need 
to download and unpack.

Note that the entire build runs 
[sandboxed](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man7/sandbox.7.html) 
to bar it from polluting your system. Keep this in mind when something fails.

This work is licensed under the [WTFPL](http://www.wtfpl.net/), so you can do anything you 
want with it.
