defmodule TwitchIrc.IrcBot.Models.UserParted do
  defstruct [:channel_name, :host, :nickname, :username]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
