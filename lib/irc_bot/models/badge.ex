defmodule TwitchIrc.IrcBot.Models.Badge do
  defstruct [:badge, :version]

  def new(data) when is_bitstring(data) do
    map = String.split(data, "/")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn ({value, index}, map) ->
      case index do
        0 -> Map.put(map, :badge, value)
        1 -> Map.put(map, :version, value)
      end
    end)
    struct(__MODULE__, map)
  end
end
