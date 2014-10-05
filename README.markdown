# Cross compiler: GCC for SWEB (i686-linux-gnu)

You can use this homebrew formula as well as the prepackaged bottles for the [Betriebssysteme][] course at the [TU Graz][].

[Betriebssysteme]: https://swebwiki.student.iaik.tugraz.at/start
[TU Graz]: http://tugraz.at

## Installation

This repository contains formulas for [homebrew][] for the cross-compiled `binutils` and `gcc`. Homebrew will automatically fetch and install the required dependencies for the cross-compiler. To add the repository and install the packages use the following commands after installing homebrew.

[homebrew]: http://homebrew.sh

    brew tap ghostlyrics/homebrew-sweb
    brew update
    brew install sweb-gcc

In order to run SWEB, you will also need the `qemu` package.

    brew install qemu

## Usage

Make sure that the homebrew packages are in your path. This should happen automatically. You can manually check if you have the corresponding two entries in your `~/.bash_profile`. In my case (default installation) these are:

    PATH=/usr/local/bin:$PATH # homebrew (1/2)
    PATH=/usr/local/sbin:$PATH # homebrew (2/2)

When you call `cmake <path>` with SWEB, the build process should automatically know you're crosscompiling and select the correct applications to build your SWEB.

## Sample build

In order to build SWEB after installing the packages, your workflow could look like this:

    git clone https://github.com/iaik/sweb
    mkdir build
    cd build
    cmake ../sweb
    make
    make qemu
