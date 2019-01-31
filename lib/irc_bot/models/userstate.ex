defmodule TwitchIrc.IrcBot.Models.Userstate do
  defstruct [:badges, :color, :display_name, :emotes, :mod]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end