# libpisoundmicro

libpisoundmicro is a straightforward C/C++ library with bindings to other languages such as Python for making use of the I/O functionalities of Pisound Micro. It completely abstracts all of the sysfs interaction details, providing a procedural or object oriented API, as well as exposing the Linux File Descriptors that can be polled to detect value changes with minimal use of host board's CPU resources.

Even though the sysfs details are completely abstracted out, it's still recommended to go through the [Sysfs Interface](sysfs-interface.md) documentation page, to gain a good understanding of the concepts and what underlying functionality is being provided.

## Setting up for Development

It's assumed that you're using Patchbox OS image, or have set up our [APT server](https://apt.blokas.io/){target="_blank"}.

### C/C++

Simply run `sudo apt install libpisoundmicro-dev` and you will get the library and its development headers installed.

### Python

Python 3 bindings library can be set up by running `sudo apt install pypisoundmicro`

## Key Concepts

### Elements

Pisound Micro exposes its I/O functionality through so called Elements - they have a name, are of a specific type (like an Analog Input or a Gpio Input), and have a specific set of attributes, depending on their type.

The Elements that are set up via libpisoundmicro are reference counted. Object oriented languages implicitly take care of releasing the references whenever necessary, tied to the lifetime of the objects. If using C. you have to keep track of it yourself.

### Element Setup

An Element gets created upon completion of a successful Setup request.

There's specific APIs for setting up desired types of Elements, however, sometimes it can be useful to use a generic `upisnd_setup_t` container type to store all the settings into it and provide it to a generic setup function which returns you an Element reference.

## C

This section is a quick overview of key concepts of C API for libpisoundmicro. There's [Reference documentation todo](https://blokas.io/){target=_blank} available as well.

The main API header to include is [`pisound-micro.h` todo](https://github.com/){target=_blank}:

```c
#include <pisound-micro.h>
```

Link with `-lpisoundmicro`.

The library uses `upisnd_` prefix for every C function and type exposed by it. You can find the C reference documentation [here](doxygen c todo){target=_blank}.

### Init

Before using the library's APIs, the library must first be initialized. Somewhere within the initial section of your `main` or dedicated initialization routine, call:

```c
upisnd_init();
```

On success, it will return 0, or -1 on failure. Inspect the `errno`'s result for insights of what could have gone wrong.

### Uninit

At your cleanup code, add a call to deinitialization function:

```c
upisnd_uninit();
```

It releases all of the Elements your program still had handles to. It's a very good idea to ensure this function gets called when signals are sent to your program's process, by setting up your own signal handlers. It's a complex topic, and is out of scope of this documentation, but feel free to look at [our programs todo](https://blokas.io/){target=_blank} written for Pisound Micro for inspiration, as well as read up on the subject from online resources. todo: add links

Starting up again without first releasing the Elements can lead to a situation where your program can't initialize properly due to Elements from previous run holding the pins you require.

### Elements

The library exposes Elements as reference counted objects, so every time you get a **valid return** of type `upisnd_element_ref_t` from various APIs, **make sure** to have a corresponding `upisnd_element_unref` call once your program no longer requires to keep the reference. `upisnd_element_add_ref` is available to increase the reference count of an Element, so you can use it in a similar manner as a smart pointer.

There's specific per-type APIs for setting up brand new Elements, like `upisnd_setup_encoder`. Upon success, you get a valid reference to the Element. If there was an already existing Element with exactly the same name and options, you'll get a valid reference to the Element (the refcount will be implicitly increased), and this case can be detected by checking if `errno` is equal to `EEXIST`. Upon any other error, you'll get an invalid reference (equal to `NULL`)

There's also a generic `upisnd_setup` API, taking a generic setup config container `upisnd_setup_t`.

Some Elements provide type specific API's, prefix with the type, for example `upisnd_element_gpio_...` or `upisnd_element_encoder_...`. See the API Reference documentation for all of them.

### Element Name

Valid Element names are null terminated strings of bytes of up to `UPISND_MAX_ELEMENT_LENGTH` (64), including the null character. Forward slash (/) character is not allowed. `upisnd_validate_element_name` can be used to validate name strings.

The Element names can be static, but there's also a helper function to generate a unique random name that you can use, either with a common prefix or without any prefix - `upisnd_generate_random_element_name`.

See the [Reference documentation todo](https://blokas.io/){target=_blank} for more details.

### Element Setup Config Container

You may build up and store the setup configuration for an Element in a `upisnd_setup_t` container. It can hold info for all of the Element's setup details, apart from the Analog Input's or Encoder's options, which are set in subsequent sysfs writes to appropriate attributes.

The first thing to do when building up the `upisnd_setup_t` is to set the Element Type. Then fill in the rest of the information which is specific for the particular type.

Finally, pass it in `upisnd_setup` API to setup an Element accordingly.

### Value

There's utility functions for getting a Unix File Descriptor opened for the Element's `value` attribute, as well as reading and writing to it. See `upisnd_element_open_value_fd`, `upisnd_value_read` and `upisnd_value_write` APIs. todo: links to APIs

The FD can be used for polling for changes, which is an efficient way to get notified once a change occurs. Use `POLLPRI`. This topic is complex and out of scope of this documentation, but there's plenty of online resources that cover it.

### An Example

See [here](doxygen docs todo){target=_blank} for a working basic C example.

## C++

The C++ API of libpisoundmicro simply wraps the C APIs into object oriented classes, so it's recommended to go through [C](libpisoundmicro.md#c) section before continuing. The C++ API also provides a helper class to help with the library's initialization and deinitialization. The Element reference counts are tied to C++ objects' lifetime, if using pure C++ API, it is not necessary to manually ref and unref `upisnd_element_ref_t` handles.

Just like for C, include `<pisound-micro.h>` to access the libpisoundmicro APIs and link your program with `-lpisoundmicro`.

All of the C++ API is within the `upisnd::` namespace. It also makes use of some C types, defined in global scope, with `upisnd_` prefix. You can find the C++ reference documentation [here](doxygen c++ todo){target=_blank}.

### Init and Uninit

There's a helper class `upisnd::LibInitializer` which initializes libpisoundmicro library in its constructor and uninitializes it in its destructor, that makes an instance of it perfectly suited to be placed into your `main` body, or a global variable, or in a static variable of an accessor function.

### Element Name

There's also a helper class for producing Element names, called `upisnd::ElementName`, use its static methods to wherever an Element has to be passed, or plain `const char *` is accepted for APIs expecting `upisnd::ElementName`.

### Value

Finally, there's `upisnd::ValueFd` class that helps with interacting with and automatically closing the opened value FD.

todo: links to APIs

### An Example

See [here](doxygen docs todo){target=_blank} for a working basic C++ example.

## Python

The Python wrapper is automatically generated from [C](libpisoundmicro.md#c) and [C++](libpisoundmicro.md#c_1) headers using SWIG, pretty much everything in C and C++ sections applies to Python, the APIs are all the same, just have to be accessed in Python 3 syntax.

The only significant difference is that the libpisoundmicro is implicitly initialized upon importing the `pypisoundmicro` library.

The recommended way to import the `pypisoundmicro` library is:

```python
from pypisoundmicro import *
```

This brings in all of the APIs into the global namespace.

### An Example

See [here](doxygen docs todo){target=_blank} for a working basic Python example.
