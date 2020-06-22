defmodule LP5024 do
  alias Circuits.I2C

  @broadcast_address 0x3C

  @register [
    device_config0: 0x00,
    device_config1: 0x01,
    led_config0: 0x02,
    bank_brightness: 0x03,
    bank_a_color: 0x04,
    bank_b_color: 0x05,
    bank_c_color: 0x06,
    led0_brightness: 0x07,
    led1_brightness: 0x08,
    led2_brightness: 0x09,
    led3_brightness: 0x0A,
    led4_brightness: 0x0B,
    led5_brightness: 0x0C,
    led6_brightness: 0x0D,
    led7_brightness: 0x0E,
    out0_color: 0x0F,
    out1_color: 0x10,
    out2_color: 0x11,
    out3_color: 0x12,
    out4_color: 0x13,
    out5_color: 0x14,
    out6_color: 0x15,
    out7_color: 0x16,
    out8_color: 0x17,
    out9_color: 0x18,
    out10_color: 0x19,
    out11_color: 0x1A,
    out12_color: 0x1B,
    out13_color: 0x1C,
    out14_color: 0x1D,
    out15_color: 0x1E,
    out16_color: 0x1F,
    out17_color: 0x20,
    out18_color: 0x21,
    out19_color: 0x22,
    out20_color: 0x23,
    out21_color: 0x24,
    out22_color: 0x25,
    out23_color: 0x26,
    reset: 0x27
  ]

  def broadcast_address(), do: @broadcast_address
  def register(register), do: @register[register]
  defdelegate open(bus_name), to: Circuits.I2C
  defdelegate detect_devices(), to: Circuits.I2C

  def put(i2c_bus, address, register, value) do
    I2C.write(i2c_bus, address, <<register(register)>> <> value)
  end

  def get(i2c_bus, address, register, bytes \\ 1) do
    I2C.write_read(i2c_bus, address, <<register(register)>>, bytes)
  end

  def reset(i2c_bus, address) do
    I2C.write(i2c_bus, address, <<@register[:reset], 0xFF>>)
  end

end
