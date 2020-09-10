defmodule Example do
  use GenServer

  require Logger

  @default_bus "i2c-1"
  @default_address LP5024.broadcast_address()
  @max_brightness 255
  @animate_interval 20

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def bank_control(enable?) do
    GenServer.call(__MODULE__, {:bank_control, enable?})
  end

  def bank_color(r, g, b) do
    GenServer.call(__MODULE__, {:bank_color, r, g, b})
  end

  def animate(animate?) do
    GenServer.call(__MODULE__, {:animate, animate?})
  end

  def init(opts) do
    bus = opts[:bus] || @default_bus
    address = opts[:address] || @default_address

    {:ok, i2c_bus} = LP5024.open(bus)

    LP5024.reset(i2c_bus, address)
    LP5024.DeviceConfig.put_key(i2c_bus, address, :chip_en, true)

    {:ok, %{
      i2c_bus: i2c_bus,
      address: address,
      animate?: false,
      animate_timer_ref: nil,
      brightness: 255,
      direction: :down
    }}
  end

  def handle_call({:bank_control, enable?}, _from, %{i2c_bus: i2c_bus, address: address} = s) do
    reply = LP5024.LEDConfig.all(i2c_bus, address, enable?)
    {:reply, reply, s}
  end

  def handle_call({:bank_color, r, g, b}, _from, %{i2c_bus: i2c_bus, address: address} = s) do
    reply = LP5024.put(i2c_bus, address, :bank_a_color, <<r, g, b>>)
    {:reply, reply, s}
  end

  def handle_call({:bank_brightness, a}, _from, %{i2c_bus: i2c_bus, address: address} = s) do
    reply = LP5024.put(i2c_bus, address, :bank_brightness, <<a>>)
    {:reply, reply, s}
  end

  def handle_call({:animate, true}, _from, %{animate?: false} = s) do
    Logger.debug "1"
    {:ok, timer_ref} = :timer.send_interval(10, :animate)
    {:reply, :ok, %{s | animate?: true, animate_timer_ref: timer_ref}}
  end

  def handle_call({:animate, false}, _from, %{animate?: true, animate_timer_ref: timer_ref} = s) do
    :timer.cancel(timer_ref)
    {:reply, :ok, %{s | animate?: false, animate_timer_ref: nil}}
  end

  def handle_call({:animate, _}, _from, s) do
    Logger.debug "1"
    {:reply, :ok, s}
  end

  def handle_info(:animate, %{i2c_bus: i2c_bus, address: address, brightness: brightness} = s) when brightness <= 0 do
    Logger.debug "2"
    brightness = brightness + 5
    LP5024.put(i2c_bus, address, :bank_brightness, <<brightness>>)
    {:noreply, %{s | brightness: brightness, direction: :up}}
  end

  def handle_info(:animate, %{i2c_bus: i2c_bus, address: address, brightness: brightness} = s) when brightness >= @max_brightness do
    Logger.debug "3"
    brightness = brightness - 5
    LP5024.put(i2c_bus, address, :bank_brightness, <<brightness>>)
    {:noreply, %{s | brightness: brightness, direction: :down}}
  end

  def handle_info(:animate, %{i2c_bus: i2c_bus, address: address, brightness: brightness, direction: direction} = s) do
    brightness =
      case direction do
        :down -> brightness - 5
        :up -> brightness + 5
      end
    Logger.debug("Set Brightness: #{brightness}")
    LP5024.put(i2c_bus, address, :bank_brightness, <<brightness>>)
    {:noreply, %{s | brightness: brightness}}
  end
end
