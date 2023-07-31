# libpisoundmicro

All of the GPIO I/O functionality of Pisound Micro is accessed through the sysfs `/sys/pisound-micro` tree. It is based around a concept of creating named Elements and assigning them to perform certain functions on the specified GPIO pins. An Element can be a digital I/O control, analog potentiometer, digital encoder or MIDI activity output.

Once an Element is created, it gets its own subdirectory under `/sys/pisound-micro/elements/` and provides a couple of files for reading & writing the value, as well as further configuration, like setting the minimum and maximum values.

`libpisoundmicro` is a library encapsulating all of the available functionality of the sysfs interface in a straightforward C/C++ API with bindings to other languages.

## Sysfs /sys/pisoundmicro interface

### Quick Start

Before you start, please make sure you have our `pollgpio` (todo: link to GitHub source code) utility installed:

```bash
sudo apt install -y pollgpio
```

#### Digital Output

First let's get acquainted by going through some quick examples. Let's hook up an LED to Pisound Micro's pin B03, connect a single color LED's anode (+) through a series resistor (usually with values between 200 Ohm and 1k Ohm, depending on your specific LED, like color, refer to its datasheet) to +3V3 (pin B01), and the cathode (-) to pin B03, then we can manually turn it on and off:

```bash
# First create a GPIO output Element named 'my_led',
# controlling pin B03 and initially setting it to high output.
echo my_led gpio B03 output 1 > /sys/pisound-micro/setup

# As both of the LEDs pins are at high voltage, no current is flowing
# and the LED is off.

# Now let's make it light up by setting the GPIO low:
echo 0 > /sys/pisound-micro/elements/my_led/value

# The LED should be lit up now. Let's turn it off again:
echo 1 > /sys/pisound-micro/elements/my_led/value

# Let's release the 'my_led' Element now, so the B03 pin can be used
# for other purposes.
echo my_led > /sys/pisound-micro/unsetup
```

An exercise for the reader - write a bash script to blink the LED on and off again every one second. Use a `for` or `while` loop to keep the script running and `sleep 0.5` to delay execution between state changes.

After you're done, disconnect the LED and the resistor.

#### Digital Input

Similarly, you may read out on and off state on any of the GPIO line of Pisound Micro hook up a momentary or toggle/slide switch to pin B03 and the other side of the switch to GND (pin B02) or just connect one end of a jumper cable to pin B03 and be prepared to short the other end to GND to see different input states. Here's how to read it out:

```bash
# Let's create a GPIO input Element named 'switch',
# with internal pull up resistor enabled:
echo switch gpio B03 input pull_up > /sys/pisound-micro/setup

# Let's read the value:
cat /sys/pisound-micro/elements/switch/value

# You'll see it output 1, if the circuit is open,
# and 0 if pin B03 is shorted to GND.

# Let's try that again a couple of times, but this time let's use
# our `pollgpio` utility to monitor the value as it changes.
pollgpio /sys/pisound-micro/elements/switch/value

# Now close the circuit on B03 and you should see the latest
# value printed in a new line every time it changes.

# Finally let's release the 'switch' Element now, so the B03 pin can be used
# for other purposes.

# Hit Ctrl+C to stop pollgpio, then:
echo switch > /sys/pisound-micro/unsetup
```

#### Analog Input / Potentiometer

By now a pattern should have emerged - to get analog readings between 0V (GND) and 3.3V, you have to set up an `analog_in` typed Element, using a pin with analog reading functionality. It provides 10 bit resolution - values between 0 and 1023. Additionally, for convenience, it's possible to limit the input range to certain values if you're not interested in the entire range using `input_low` and `input_high` sysfs attributes, as well as remap the output value range to values that fit your application, including reversing the polarity, using `value_low` and `value_high` sysfs attributes. Here's a quick example project - take any 3 pin single channel potentiometer you have, connect its 1st pin to GND, the 2nd to pin B23 and the 3rd to +3V3. A classic voltage divider circuit. Then:

```bash
# Let's create an analog_in Element named 'pot' on pin B23:
echo pot analog_in B23 > /sys/pisound-micro/setup

# Now let's monitor its value:
pollgpio /sys/pisound-micro/elements/pot/value

# It should immediately print out the current value,
# try rotating the shaft to see the values change.

# Keep pollgpio running in this terminal to see changes
# in real time, and start another session in another terminal
# window for the rest of the commands.

# Let's say we're not satisfied with the change direction.
# Not so quick! There's no need to physically swap pins 1
# and 3, # we can change the direction simply by reconfiguring
# the value_low and value_high attributes:
echo 1023 > /sys/pisound-micro/elements/pot/value_low
echo 0 > /sys/pisound-micro/elements/pot/value_high

# Now let's say for one reason or another we're only interested in
# the first half of voltage value range (0V ~ 1.65V), we want any
# value higher than 1.65V to be clamped to maximum. We can get such
# readings by adjusting the input_low and input_high attributes:
echo 0 > /sys/pisound-micro/elements/pot/input_low
echo 511 > /sys/pisound-micro/elements/pot/input_high

# Now you should get only 1023 readings for the top half, and readings
# between 0 and 1023 for the bottom half. The 0-511 range is mapped to
# 0 - 1023 range. To make it map directly to the values you used to get
# just previously, we should change 1023 of value_low to 511:
echo 511 > /sys/pisound-micro/elements/pot/value_low

# Let's stop pollgpio on original terminl and release the Element:
# Hit Ctrl+C while the pollgpio terminal is active and execute:
echo pot > /sys/pisound-micro/unsetup
```

#### Encoder

Quadrature encoders are handled similarly to analog inputs described above, they do have one more attribute though - `value_mode`, which configures what happens when the highest or lowest value is reached - should it stay there, or wrap to the other end. The encoders are best placed on pins between B03 and B18. Let's give it a spin - hook up a quadrature encoder's 1st pin to B03, the 2nd pin to GND and the 3rd pin to B04, then:

```bash
# Let's setup 'enc' Element on pins B03 and B04 with internal pull-ups
# enabled:
echo enc encoder B03 pull_up B04 pull_up > /sys/pisound-micro/setup

# Let's reduce the maximum value range to 23:
echo 23 > /sys/pisound-micro/elements/enc/input_high
echo 23 > /sys/pisound-micro/elements/enc/value_high

# Now start monitoring the value:
pollgpio /sys/pisound-micro/elements/enc/value

# You should first see 0, spinning it one direction should increase
# the values, the other direction should decrease the values, but
# it shouldn't go below 0 or above 23, as the default value_mode is
# to clamp the values. Let's give wrap mode a try, in another terminal
# session, do:
echo wrap > /sys/pisound-micro/elements/enc/value_mode

# Now spinning below 0 should wrap over to 23, spinning above 23
# should wrap over to 0.

# A nice feature of encoders is that it updates the values in relative
# manner to the previous value, instead of being an absolute control
# like potentiometers. This enables for smooth value transitions when
# a value is changed externally using some other control method, like a UI
# control and a mouse, the encoder can be kept up to date by writting to
# its value attribute. Try this:

echo 17 > /sys/pisound-micro/elements/enc/value

# Now twist one way or the other, you should see the value change without
# any jumps to either to 16  or 18, regardless of what value was set prior
# to our explicit value change using the above command.

# As encoders only produce usually between 12 or 24 value changes in 360
# degree turns, it can be convenient to expand its output value range to
# something larger:

echo 1023 > /sys/pisound-micro/elements/enc/value_high

# Now there should be changes in steps of ~43, and the maximum value should
# be 1023.

# There's 2 ways to change the polarity of the encoder - either, just like
# with analog input, swap the value_high and value_low, or re-setup with
# the pins swapped places.

# Method 1:
echo 0 > /sys/pisound-micro/elements/enc/value_high
echo 1023 > /sys/pisound-micro/elements/enc/value_low

# Method 2, first unsetup the encoder, then set it up again differently:
echo enc > /sys/pisound-micro/unsetup
echo enc encoder B04 pull_up B03 pull_up > /sys/pisound-micro/setup

# Note that there's no event produced by the kernel telling that the
# file monitored by pollgpio has disappeared, it will get stuck with no
# further changes detected. It has to be restarted, by doing Ctrl+C and
# starting it again:
pollgpio /sys/pisound-micro/elements/enc/value

# Finally finish up by hitting Ctrl+C and releasing the 'enc' Element:
echo enc > /sys/pisound-micro/unsetup
```

#### MIDI Activity LED

This is a simple automatic output Element, either indicating activity on MIDI input or output. First, connect two single color LEDs, one using signal line B03, the other B04, in the following way - the LED's anode (+) should be connected through a series resistor (usually with values between 200 Ohm and 1k Ohm, depending on your specific LED, like color, refer to its datasheet) to +3V3 (pin B01), and the cathode (-) pin should be connected to one of aforementioned GPIO lines. Then set them up:

```bash
echo act_in activity_midi_in B03 > /sys/pisound-micro/setup
echo act_out activity_midi_out B04 > /sys/pisound-micro/setup

# Produce some MIDI output:
amidi -p hw:pisound-micro -S "90 40 30"

# You should see the activty indicated on the LED connected to B04.
```

For observing MIDI input, either have a MIDI connector hooked up to the MIDI input pins and send it some data using external MIDI devices, or if there's no connector hooked up, you may temporarily short two pairs of pins A21 with A24 and A23 with A22, then produce MIDI output using the `amidi` command above, the produced data should be sent to Pisound Micro's input and should have the activity indicated on the LED connected to B03.

### Reference
