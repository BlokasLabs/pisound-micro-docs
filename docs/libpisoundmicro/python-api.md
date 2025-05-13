# Python API

The Python API reference documentation for libpisoundmicro. It closely resembles the
\ref cpp, refer to its documentation for detailed information on the available APIs.
The Python wrapper is automatically generated from the C/C++ API using SWIG. The generated
code includesautodoc comments, so the same reference documentation is available straight in
your favorite IDE.

The only major difference from C and C++ APIs is that the libpisoundmicro is implicitly
initialized when importing the `pypisoundmicro` library in Python, and deinitialized upon
exit.

## Quick Start

First, install the Python library package:

```bash
sudo apt install pypisoundmicro
```

Then, let's create a simple program to read the GPIO value of pin B03:

```py3
#!/usr/bin/env python3

# Import the pisoundmicro module, make all of it available in global namespace.
from pypisoundmicro import *

# Set up the Gpio Input Element using pin B03 with pull-up enabled.
gpio = Gpio.setupInput(ElementName.randomized(), UPISND_PIN_B03, UPISND_PIN_PULL_UP)

# Check if the setup was successful.
if not gpio.isValid():
	print("GPIO setup failed")
	exit(1)

# Read the GPIO value.
if gpio.get():
	print("B03 is high.")
else:
	print("B03 is low.")
```

Save the code as `example.py`, make it executable:

```bash
chmod +x example.py
```

Then run it:

```bash
./example.py
```

You should see it output either "_B03 is high._" or "_B03 is low._", depending on the B03 pin state.

## Classes

::: pypisoundmicro
	options:
		filters:
			- "!^_"

