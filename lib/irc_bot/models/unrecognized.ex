defmodule TwitchIrc.IrcBot.Models.Unrecognized do
  defstruct [:raw_msg]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
