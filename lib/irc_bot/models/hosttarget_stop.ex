defmodule TwitchIrc.IrcBot.Models.HosttargetStop do

  defstruct [:viewers]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
