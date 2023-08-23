# Gpiod & libpgio

The modern way of accessing GPIOs on Linux is to access them through the `/dev/gpiochip*` character devices. There's a suite of utilities called `gpiod` as well as a C library with C++ wrapper called `libgpiod`. They provide more flexibility for dealing with the GPIOs, including more ways to configure them, and ways to change multiple pins at once.

This is just a quick overview of the available tools and the library, you may dig deeper into their documentation at [libgpiod.git](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/tree/README){target=_blank} as well as the manual pages of the mentioned utilities on your device by running for example `man gpioset`.

## Gpiod

First let's make sure you have `gpiod` installed:

```bash
sudo apt install -y gpiod
```

Then there's a handful of convenient and quick to use utilities to immediately make changes to the GPIOs.

### Determining the Gpiochip

The first step is to find out which gpiochip corresponds to Pisound Micro, this can be done like so:

```bash
gpiodetect
```

It will list a couple of gpiochip devices, including the Pisound Micro one, example output:

```
gpiochip0 [pinctrl-bcm2711] (58 lines)
gpiochip1 [raspberrypi-exp-gpio] (8 lines)
gpiochip2 [pisound-micro-gpio] (37 lines)
```

As you guessed it, we're interested in gpiochip2. It can be used with the rest of the `gpio*` utilities verbatim, or in short, it can be referenced just by the plain number 2.

### Querying for Information

Now we can use `gpioinfo` utility to list out all the GPIOs of Pisound Micro:

```bash
gpioinfo 2
```

Example output:

```
gpiochip2 - 37 lines:
        line   0:        "A27"       unused   input  active-high
        line   1:        "A28"       unused   input  active-high
        line   2:        "A29"      "sysfs"   input  active-high [used]
        line   3:        "A30"       unused   input  active-high
        line   4:        "A31"       unused   input  active-high
...
```

Note the `"sysfs"` and `[used]` properties on line 2 - this indicates that the pin is already in use by the sysfs gpio class, and therefore is not available at the moment for use by other means. `gpioinfo` is useful to get a quick overview of the current situation of the GPIO pins, especially when debugging.

We're interested in the line numbers, as they are used to refer to the actual pins, for example, line 1 refers to the Pisound Micro's pin A28.

Another way to find this information is by making use of the `gpiofind` utility, let's say we're looking for pin A28:

```bash
gpiofind A28
```

It will output:

```
gpiochip2 1
```

which is the gpiochip device ID and the line number to use.

### Setting Up an Output

Let's make A28 pin an output, set to value 0, for 15 seconds:

```
gpioset 2 1=0 -m time -s 15
```

Upon exit of this utility, the pin gets released and reverts to its default configuration of being a Hi-Z input.

You may set multiple GPIO output values by adding more `line=...` arguments, for example, let's set A31 to high and A30 to low for 10 seconds:

```
gpioset 2 4=1 3=0 -m time -s 10
```

### Reading an Input

Let's now read out the value of GPIO B03 with pull-up enabled, this time we'll use `gpiofind` within the argument list to figure out the device ID and the line number for us:

```bash
gpioget -B pull-up $(gpiofind B03)
```

It prints the instantaneous value once, after configuring the pin for input. A way to continuously see the level is to use the `gpiomon` utility:

```bash
gpiomon -B pull-up $(gpiofind B03)
```

You will see it print a line each time the pin state changes, for example:

```
event: FALLING EDGE offset: 6 timestamp: [   15275.783939543]
event:  RISING EDGE offset: 6 timestamp: [   15275.798515492]
```

## libgpiod

Fully documenting the powerful `libgpiod` library upon which the above utilities are built is a little bit out of the scope for Pisound Micro's docs, but this won't stop us from getting you on the right track and making you comfortable.

### Prerequisities

Install the `libgpiod-dev` package:

```bash
sudo apt install -y libgpiod-dev
```

### Documentation

You may want to install the library's Doxygen documentation:

```
sudo apt install -y libgpiod-docs
```

Open [`/usr/share/doc/libgpiod-dev/html/index.html`](file:///usr/share/doc/libgpiod-dev/html/index.html){target=_blank} to browse it. (the link works only on a device which has `libgpiod-docs` installed.)

### An Example

Here's a quick example of reading B03 and outputting values on B04 to get you started. Refer to the [libgpiod documentation](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/about/){target=_blank} for more details. Save the below contents to a file named `libgpio_example.cpp`:

```cpp
#include <gpiod.hpp>
#include <iostream>
#include <string>
#include <unistd.h>

gpiod::chip find_chip(const std::string &label)
{
    const gpiod::chip_iter end = gpiod::chip_iter();
    for (gpiod::chip_iter itr = gpiod::make_chip_iter(); itr != end; ++itr)
    {
        if (itr->label() == label)
        {
            return *itr;
        }
    }

    return gpiod::chip();
}

int main(int argc, char **argv)
{
    gpiod::chip chip = find_chip("pisound-micro-gpio");

    if (!chip)
    {
        std::cerr << "Couldn't locate the gpio chip for Pisound Micro!";
        std::cerr << std::endl;
        return 1;
    }

    gpiod::line b03 = chip.find_line("B03");
    gpiod::line b04 = chip.find_line("B04");

    if (!b03 || !b04)
    {
        std::cerr << "Couldn't locate the gpio lines for Pisound Micro!";
        std::cerr << std::endl;
        return 1;
    }

    std::cout << "Setting up B03 as an input with pull-up enabled and "
        "B04 as an output." << std::endl;

    b03.request({ "example", gpiod::line_request::DIRECTION_INPUT,
        gpiod::line_request::FLAG_BIAS_PULL_UP });
    b04.request({ "example", gpiod::line_request::DIRECTION_OUTPUT, 0 }, 1);

    if (!b03.is_requested() || !b04.is_requested())
    {
        std::cerr << "Couldn't request the gpio lines for Pisound Micro!";
        std::cerr << std::endl;
        return 1;
    }

    std::cout << "Will now toggle B04 every second for 4 seconds.";
    std::cout << std::endl;
    std::cout << std::endl;

    for (int i=0; i<4; ++i)
    {
        // Print the state of B03 and B04.
        std::cout << i;
        std::cout << " B03: " << b03.get_value();
        std::cout << " B04: " << b04.get_value();
        std::cout << std::endl;

        sleep(1);

        // Flip the state of B04.
        b04.set_value(!b04.get_value());
    }

    return 0;
}
```

Build and link it like so:

```bash
g++ libgpiod_example.cpp -lgpiodcxx -o libgpiod_example
```

Run it:

```bash
./libgpiod_example
Setting up B03 as an input with pull-up enabled and B04 as an output.
Will now toggle B04 every second for 4 seconds.

0 B03: 1 B04: 1
1 B03: 1 B04: 0
2 B03: 1 B04: 1
3 B03: 1 B04: 0
```
