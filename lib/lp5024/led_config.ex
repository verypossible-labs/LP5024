defmodule LP5024.LEDConfig do
  alias Circuits.I2C

  import LP5024.Utils

  @register LP5024.register(:led_config0)

  defstruct [
    led0_bank_en: false,
    led1_bank_en: false,
    led2_bank_en: false,
    led3_bank_en: false,
    led4_bank_en: false,
    led5_bank_en: false,
    led6_bank_en: false,
    led7_bank_en: false,
  ]

  def put_key(i2c_bus, address, key, value) do
    case get(i2c_bus, address) do
      {:ok, config} -> put(i2c_bus, address, Map.put(config, key, value))
      error -> error
    end
  end

  def get_key(i2c_bus, address, key) do
    case get(i2c_bus, address) do
      {:ok, config} -> Map.get(config, key)
      error -> error
    end
  end

  def put(i2c_bus, address, %__MODULE__{} = config) do
    I2C.write(i2c_bus, address, <<@register>> <> encode(config))
  end

  def get(i2c_bus, address) do
    case I2C.write_read(i2c_bus, address, <<@register>>, 1) do
      {:ok, data} -> {:ok, decode(data)}
      error -> error
    end
  end

  def all(i2c_bus, address, enable?) do
    led_config =
      %__MODULE__{
        led0_bank_en: enable?,
        led1_bank_en: enable?,
        led2_bank_en: enable?,
        led3_bank_en: enable?,
        led4_bank_en: enable?,
        led5_bank_en: enable?,
        led6_bank_en: enable?,
        led7_bank_en: enable?,
      }
    put(i2c_bus, address, led_config)
  end

  def decode(data) do
    <<
      led0_bank_en :: size(1),
      led1_bank_en :: size(1),
      led2_bank_en :: size(1),
      led3_bank_en :: size(1),
      led4_bank_en :: size(1),
      led5_bank_en :: size(1),
      led6_bank_en :: size(1),
      led7_bank_en :: size(1),
    >> = data
    %__MODULE__{
      led0_bank_en: to_bool(led0_bank_en),
      led1_bank_en: to_bool(led1_bank_en),
      led2_bank_en: to_bool(led2_bank_en),
      led3_bank_en: to_bool(led3_bank_en),
      led4_bank_en: to_bool(led4_bank_en),
      led5_bank_en: to_bool(led5_bank_en),
      led6_bank_en: to_bool(led6_bank_en),
      led7_bank_en: to_bool(led7_bank_en),
    }
  end

  def encode(%__MODULE__{} = config) do
    <<
      to_int(config.led0_bank_en) :: size(1),
      to_int(config.led1_bank_en) :: size(1),
      to_int(config.led2_bank_en) :: size(1),
      to_int(config.led3_bank_en) :: size(1),
      to_int(config.led4_bank_en) :: size(1),
      to_int(config.led5_bank_en) :: size(1),
      to_int(config.led6_bank_en) :: size(1),
      to_int(config.led7_bank_en) :: size(1),
    >>
  end
end
