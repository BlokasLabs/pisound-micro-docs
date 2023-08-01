# libpisoundmicro

libpisoundmicro is a straightforward C/C++ library with bindings to other languages for making use of the I/O functionalities of Pisound Micro. It completely abstracts all of the sysfs interaction details, providing a procedural or object oriented API, as well as exposing the Linux File Descriptors that can be polled to detect value changes with minimal use of host board's CPU resources.

Even though the sysfs details are completely abstracted out, it's still recommended to go through the [Sysfs Interface](sysfs-interface.md) page, to gain a good understanding of the concepts and what functionality is being provided.

## Setting up for Development

It's assumed that you're using Patchbox OS image, or have set up our [APT server](https://apt.blokas.io/){target="_blank"}.

### C/C++

Simply run `sudo apt install libpisoundmicro-dev` and you will get the library and its development headers installed.

### Python

Python 3 bindings library can be set up by running `sudo apt install pypisoundmicro`

## C

## C++

## Python