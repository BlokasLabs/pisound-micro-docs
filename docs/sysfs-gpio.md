# Sysfs GPIO

The deprecated, yet classic method of accessing GPIO on Linux that's still sometimes in use in this and that program or script. Pisound Micro wouldn't be complete without providing this access method.

The GPIOs are configured and accessed through the interface provided by `/sys/class/gpio` tree.

Refer to [Linux kernel documentation](https://www.kernel.org/doc/Documentation/gpio/sysfs.txt){target=_blank} on the topic for more details.

Before continuing, it's recommended to make sure you have `gpiod` and `pollgpio` (from [Blokas APT server](https://apt.blokas.io/){target=_blank}) installed:

```bash
sudo apt install -y gpiod pollgpio
```

## Determining the GPIO Base

First step is to find the GPIO base number for Pisound Micro. This can be done by inspecting all the GPIO chips available to the system:

```bash
cat $(dirname $(grep -l pisound-micro-gpio /sys/class/gpio/gpiochip*/label))/base
```

It searches for the GPIO chip with label 'pisound-micro-gpio' and outputs its `base` attribute. Example output:

```bash
467
```

We'll have to add the GPIO pin number to the base in order to configure the desired pin, more on this later.

## The GPIO Pin Number

Next you have to find out the GPIO pin number of the pin you want to use. `gpioinfo` command is perfect to inspect all the available pins:

```bash
gpioinfo $(gpiodetect | grep pisound-micro-gpio | awk '{print $1;}')
```

You should get output like this:

```
gpiochip2 - 37 lines:
        line   0:        "A27"       unused   input  active-high
        line   1:        "A28"       unused   input  active-high
        line   2:        "A29"       unused   input  active-high
        line   3:        "A30"       unused   input  active-high
...
```

We're mainly interested in the line numbers - for example, if we want to use Pisound Micro's pin A29, its line number to use would be 2.

## Exporting a Pin

The next step is to export the pin. To do that, we have to echo the base summed with line number to `/sys/class/gpio/export`. For example, to export Pisound Micro's pin A29, we have to sum the base (467) with its line number (2) and echo the resulting sum into the sysfs attribute:

```bash
echo 469 > /sys/class/gpio/export
```

A new sysfs subtree will appear: `/sys/class/gpio/A29`.

## Configuring the Exported Pin

The exported pin has the following attributes under `/sys/class/gpio/A29`:

| Attribute {width=15%}| Accepted Values | Description |
| ------------ | --------------- | ----------- |
| `active_low` | `0`, `1`        | Whether the logic is inversed (setting `value` to 0 will result in high pin state). |
| `direction`  | `in`, `out`     | The direction of the pin. |
| `edge`       | `none`, `rising`, `falling`, `both` | If set to a value other than `none`, the `value` can be polled to detect edges of the connected signal. |
| `value`      | `0`, `1`        | Depending on the `direction`, either the current input level or the output level. |

### Setting Up as an Output

To set up the pin as an output, do:

```bash
echo out > /sys/class/gpio/A29/direction
```

Then you can write 0 or 1 to the value to change its output level:

```
echo 1 > /sys/class/gpio/A29/value
echo 0 > /sys/class/gpio/A29/value
```

### Setting Up as an Input

Do:

```bash
echo in > /sys/class/gpio/A29/direction
```

Then you can read out the value:

```bash
cat /sys/class/gpio/A29/value
```

To enable polling for changes on the `value` file, set which edges to detect:

```bash
echo both > /sys/class/gpio/A29/edge
```

Now external value changes of the pin will cause the Unix `poll` or `select` APIs to return once the signal level change is detected, let's see this in action using the `pollgpio` utility:

```bash
pollgpio /sys/class/gpio/A29/value
```

Every time the value change is detected, it should print the latest value in a new line. If `edge` would be set up as `rising`, new lines should be printing `1` whenever state transition from low to high occurs. Hit Ctrl+C to exit the utility.
