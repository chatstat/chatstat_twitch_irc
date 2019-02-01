defmodule TwitchIrc.IrcBot.Models.Clearchat do
  defstruct [:ban_duration, :user]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
