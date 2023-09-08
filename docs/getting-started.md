# Getting Started

## Hardware Setup

The Pisound Micro comes with no header or audio / MIDI connectors pre-soldered, offering maximum flexibility for your project's layout. However you decide to go is entirely up to you, but we'll share some basic connection schemes to get you going.

### Hooking up to Raspberry Pi

#### Mounting on Top

For mounting Pisound Micro directly on top of the Raspberry Pi, you'll want to use a 2x20 female pin header with 2.54mm (0.1") pitch. You may find 40 pin headers with pins of different lengths (todo: link į toby / digikey?), ones with long pins are useful for stacking something additional on top or making additional connections using female cable jumpers or soldering directly to the protruding pins. You may use headers with short pin length too, as the entire 40 pin GPIO header is duplicated alongside for easy access to the Raspberry Pi GPIOs.

The recommended way of soldering the female pin header is to insert it from the bottom side of Pisound Micro (the bottom is without any electronic components) to the holes marked with `rpi>`, solder a corner pin, then inspect the header alignment. If any adjustment is needed, reheat the solder, move the header into the correct position, and hold it there until the solder cools down and stiffens. Then solder a diagonal corner pin, so the header is secured in a stable position. Then continue soldering every pin. If you think you're spending too much time on a single pin, you may want to skip a few pins forward for soldering and come back to the previous location, to avoid overheating the area.

#### Cable / Wire Connection

Another option is to connect just the pins used (or all 40 pins) between the boards at the matching locations of the 40 pin `rpi>` header. The square hole indicates the very first pin. The pin numbering matches the numbering at [pinout.xyz](https://pinout.xyz){target=_blank}

You may either opt to solder wires directly into the holes or use a 2x20 male header with 2.54mm (0.1") pitch with female cable jumpers or a ribbon cable with an IDC connector.

??? "The Pins That Must Be Connected Together"

    <br/>All of the named pins must be hooked up at matching positions between the boards.

    |               |              |
    | ------------- | ------------ |
    | 1. 3.3V Power | 2. 5V Power  |
    | 3. SDA        | 4. 5V Power  |
    | 5. SCL        | 6. GND       |
    | 7. ...        | 8. ...       |
    | 9. GND        | 10. ...      |
    | 11. ...       | 12. PCM CLK  |
    | 13. ...       | 14. GND      |
    | 15. ...       | 16. ...      |
    | 17. 3.3V Power| 18. ...      |
    | 19. ...       | 20. GND      |
    | 21. ...       | 22. ...      |
    | 23. ...       | 24. ...      |
    | 25. GND       | 26. ...      |
    | 27. ...       | 28. ...      |
    | 29. ...       | 30. GND      |
    | 31. ...       | 32. ...      |
    | 33. ...       | 34. GND      |
    | 35. PCM FS    | 36. GPIO16   |
    | 37. GPIO 26   | 38. PCM DIN  |
    | 39. GND       | 40. PCM DOUT |

You may either use separate wires/cables for each connection, or just use a 40 way ribbon cable.

* Separate Wires/Cables - solder individual cables at matching positions for every named signal in the above table. In case the name matches on multiple pins (3.3V Power, 5V Power, GND), you may hook the pin holes to a single carrier cable, and split it out at the other end. Recommended wire gauge is around 26 AWG. Strive for equal and as short as possible cable length.

* Ribbon Cable - solder each of ribbon cable's contacts in sequence, following the header pin numbering scheme, starting from the 1st contact, indicated by the red stripe on the cable. If using rainbow colored cable, take care to ensure you identified the 1st pin correctly.

    You may want to doublecheck the connection ordering with a multimeter in beep mode once you're done, to make sure no pins were mistakenly swapped.

### Wiring Connectors

#### Audio

#### MIDI

## Initial Software Setup

### APT Server Setup

```sh
curl https://blokas.io/apt-setup.sh | sh
```

### Software and Default Configs

Before loading up the kernel module for Pisound Micro, it's recommended to install
the default software and configuration packages:

```sh
sudo apt install pisound-micro
```

### Setting up the Boot Config

To make the Pisound Micro's kernel driver load automatically on system startup, the
[`/boot/config.txt`](https://www.raspberrypi.com/documentation/computers/config_txt.html){target=_blank} should be modified:

```sh
sudo nano /boot/config.txt
```

Add the following at the end of the file:

```
[all]
dtoverlay=pisound-micro
dtparam=i2c_arm=on,i2c_arm_baudrate=400000
```

This enables the Device Tree overlay for Pisound Micro, as well as enables the I²C bus and sets its speed to 400kHz.

Hit Ctrl+X, then Y to save your changes and exit.

Finally, a reboot is required for changes to take place:

```sh
sudo reboot
```

## Verifying it Works

Once the Initial Setup is complete and the system booted up again, you may check the output of the following commands:

```sh
aplay -l
arecord -l
amidi -l
```

These commands list all the playback, recording and MIDI devices currently available on the system. You should see output similar to:

```
aplay -l
...
card 3: pisoundmicro [pisoundmicro], device 0: PSM-1234567 adau-hifi-0 [PSM-1234567 adau-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
...

arecord -l
...
card 3: pisoundmicro [pisoundmicro], device 0: PSM-1234567 adau-hifi-0 [PSM-1234567 adau-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
...

amidi -l
...
IO  hw:3,0    pisound-micro PSM-1234567
...
```

If you don't see the Pisound Micro listed by any of the above utilities, feel free to ask for assistance on our [community forums](https://community.blokas.io/){target=_blank}.

## Using Pisound Micro


