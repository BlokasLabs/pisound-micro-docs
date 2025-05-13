# Python API

## Detailed Description

The Python API reference documentation for libpisoundmicro presents a clean interface that mirrors the 
[C++ API](cpp.md) while following standard Python conventions. Built as a Python layer on top of SWIG-generated 
C/C++ bindings, the API provides comprehensive documentation through Python docstrings, making it fully accessible 
within any Python IDE's autocompletion and help systems.

The only major difference from C and C++ APIs is that the libpisoundmicro is implicitly
initialized when importing the `pypisoundmicro` library in Python, and deinitialized upon
exit.

For robust applications, it is recommended to install signal handlers that would enforce cleanup, see
[`cleanup`](#pypisoundmicro.cleanup) function documentation for an example.

## Quick Start

First, install the Python library package:

```bash
sudo apt install pypisoundmicro
```

Then, let's create a simple program to read the GPIO value of pin B03:

```py3
#!/usr/bin/env python3

# Import the pisoundmicro module, make it available under shorthand 'psm'.
import pypisoundmicro as psm

# Set up the Gpio Input Element using pin B03 with pull-up enabled.
gpio = psm.Gpio.setup_input(psm.ElementName.randomized(),
							psm.Pin.B03,
							psm.PinPull.UP)

# Check if the setup was successful.
if not gpio.is_valid:
	print("GPIO setup failed")
	exit(1)

# Read the GPIO value.
if gpio.get_value():
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

