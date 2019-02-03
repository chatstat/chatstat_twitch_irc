defmodule TwitchIrc.IrcBot.Models.Badges do
  alias TwitchIrc.IrcBot.Models.Badge

  defstruct [:badges]

  def update_map(map) when is_map(map) do
    case Map.has_key?(map, :badges) do
      true -> Map.put(map, :badges, new(map.badges))
      false -> Map.put(map, :badges, nil)
    end
  end

  def new("") do
    nil
  end

  def new(nil) do
    nil
  end

  def new(data) when is_bitstring(data) do
    badges = String.split(data, ",")
    |> Enum.map(fn(badge) ->
      Badge.new(badge)
    end)
    %__MODULE__{
      badges: badges
    }
  end
end
