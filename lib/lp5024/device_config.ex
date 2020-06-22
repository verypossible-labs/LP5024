defmodule LP5024.DeviceConfig do
  alias Circuits.I2C

  import LP5024.Utils

  @register LP5024.register(:device_config0)

  defstruct [
    chip_en: false,
    log_scale_en: true,
    power_save_en: true,
    auto_incr_en: true,
    pwm_dithering_en: true,
    max_current_option: false,
    led_global_off: false
  ]



  def put(i2c_bus, address, %__MODULE__{} = config) do
    I2C.write(i2c_bus, address, <<@register>> <> encode(config))
  end

  def get(i2c_bus, address) do
    case I2C.write_read(i2c_bus, address, <<@register>>, 2) do
      {:ok, data} -> {:ok, decode(data)}
      error -> error
    end
  end

  def decode(data) do
    <<
      _ :: size(1),
      chip_en :: size(1),
      _ :: size(8),
      log_scale_en :: size(1),
      power_save_en :: size(1),
      auto_incr_en :: size(1),
      pwm_dithering_en :: size(1),
      max_current_option :: size(1),
      led_global_off :: size(1)
    >> = data
    %__MODULE__{
      chip_en: to_bool(chip_en),
      log_scale_en: to_bool(log_scale_en),
      power_save_en: to_bool(power_save_en),
      auto_incr_en: to_bool(auto_incr_en),
      pwm_dithering_en: to_bool(pwm_dithering_en),
      max_current_option: to_bool(max_current_option),
      led_global_off: to_bool(led_global_off)
    }
  end

  def encode(%__MODULE__{} = config) do
    <<
      0 :: size(1),
      to_int(config.chip_en) :: size(1),
      0 :: size(8),
      to_int(config.log_scale_en) :: size(1),
      to_int(config.power_save_en) :: size(1),
      to_int(config.auto_incr_en) :: size(1),
      to_int(config.pwm_dithering_en) :: size(1),
      to_int(config.max_current_option) :: size(1),
      to_int(config.led_global_off) :: size(1)
    >>
  end
end
