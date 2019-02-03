defmodule TwitchIrc.IrcBot.Models.HosttargetStart do

  defstruct [:channel, :viewers]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
