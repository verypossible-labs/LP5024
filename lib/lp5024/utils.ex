defmodule LP5024.Utils do

  def to_bool(0), do: false
  def to_bool(1), do: true

  def to_int(false), do: 0
  def to_int(true), do: 1
end
