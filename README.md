# LP5024

This project is part of [Very labs](https://github.com/verypossible-labs/docs/blob/master/README.md).
---

LP5024, 24-Channel, 12-Bit, PWM Ultralow-Quiescent-Current, I2C RGB LED Drivers

[Product page](https://www.ti.com/product/LP5024)
[Data sheet](https://www.ti.com/lit/gpn/lp5024)

## Usage

The LED driver has a software chip enable as well as a hardware chip enable pin.
It is beyond the scope of this library to control the hardware chip enable pin.
See the data sheet for more information on controlling this via a GPIO or by
connecting it to VCC. The following instructions assume that the hardware chip
enable pin is high.

You will need to identify the address for the device that you want to communicate
with. The address of the LP5024 is configured by the address pins. See the data
sheet for more information. All devices also respond to a broadcast address `0x3C`.
In the following examples, we have the LP5024 configured with both address pins
tied to ground. This makes the address of the device `0x28`.

Identify the bus name that your device is connected to. You can call `detect_devices`
to find this information if you are unsure.

```
iex> LP5024.detect_devices
Devices on I2C bus "i2c-1":
 * 40
 * 60

2 devices detected on 1 I2C buses
```

Open the bus and hold the reference for the lifespan of your connection.

```
iex> LP5024.open("i2c-1")
{:ok, #Reference<0.85386939.268828685.85421>}
```

Configure the device to set the software chip enable to high.

```
iex> LP5024.DeviceConfig.put_key(i2c, address, :chip_en, true)
:ok
```

Other device configuration values can be found in the docs for `LP5024.DeviceConfig`

You can reset the default state of all registers by calling `LP5024.reset(i2c, address)`.

## Bank controlling LEDs

Bank control multiple LEDs to be controlled with the same brightness and color
values. Each RGB LED can be configured to use bank control or independent
control using the `LEDConfig`.

Configure a couple LEDs to use bank control.

```
iex> LP5024.LEDConfig.put_key(i2c, address, :led0_bank_en, true)
:ok
iex> LP5024.LEDConfig.put_key(i2c, address, :led1_bank_en, true)
:ok
```

You could also easily configure them all

```
iex> LP5024.LEDConfig.all(i2c, address, true)
:ok
```

### Controlling bank brightness

Controlling the brightness of bank controlled LEDs. You can specify a number
between 0 - 255.

```
iex> LP5024.put(i2c, address, :bank_brightness, <<255>>)
:ok
```

### Controlling bank color

Controlling the RBG value for all bank controlled LEDs.
The following keys control the RGB mix for the bank controlled LEDS.

* bank_a_color: Red
* bank_b_color: Green
* bank_c_color: Blue

Colors can be set individually to a value between 0 - 255

```
iex> LP5024.put(i2c, address, :bank_a_color, <<255>>)
:ok
```

If auto increment mode is enabled (default = true) you can set all three with a
single command.

```
iex> LP5024.put(i2c, address, :bank_a_color, <<255, 255, 255>>)
:ok
```

## Individually controlling LEDs

LEDs can be individually controlled if there LED config has bank_en set to false
(default = false).

Configure a couple LEDs to be independently controlled.

```
iex> LP5024.LEDConfig.put_key(i2c, address, :led0_bank_en, false)
:ok
iex> LP5024.LEDConfig.put_key(i2c, address, :led1_bank_en, false)
:ok
```

You could also easily configure them all

```
iex> LP5024.LEDConfig.all(i2c, address, false)
:ok
```

### Controlling LED Brightness

Controlling the brightness of a single LED. You can specify a number
between 0 - 255.

```
iex> LP5024.put(i2c, address, :led0_brightness, <<255>>)
:ok
```

If auto increment mode is enabled (default = true) you can set brightness
for a contiguous group. In this example, we are setting the brightness for all
8 RGB LEDs.

```
iex> LP5024.put(i2c, address, :led0_brightness, <<255, 255, 255, 255, 255, 255, 255, 255>>)
:ok
```

### Controlling LED color

Controlling the RBG value for all bank controlled LEDs.
The following keys control the RGB mix for the bank controlled LEDS.

* out0_color: Red (LED0)
* out1_color: Green (LED0)
* out2_color: Blue (LED0)
...
* out(r)_color: Red (LEDn)
* out(g)_color: Green (LEDn)
* out(b)_color: Blue (LEDn)

Colors can be set individually to a value between 0 - 255

```
iex> LP5024.put(i2c, address, :out0_color, <<255>>)
:ok
```

If auto increment mode is enabled (default = true) you can set all three with a
single command.

```
iex> LP5024.put(i2c, address, :out0_color, <<255, 255, 255>>)
:ok
```

You can also set color for a contiguous group.
In this example, we are setting the color to white for LED0 and LED1.

```
iex> LP5024.put(i2c, address, :out0_color, <<255, 255, 255, 255, 255, 255>>)
:ok
```
