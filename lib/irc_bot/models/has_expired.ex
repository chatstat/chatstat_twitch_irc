defmodule TwitchIrc.IrcBot.Models.HasExpired do
  defstruct [:expired]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
