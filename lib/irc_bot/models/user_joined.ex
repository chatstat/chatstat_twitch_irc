defmodule TwitchIrc.IrcBot.Models.UserJoined do
  defstruct [:id, :channel_name, :host, :nickname, :username]

  alias TwitchIrc.UUID

  def new(data_map) when is_map(data_map) do
    data_map = data_map
    |> UUID.add_id()
    struct(__MODULE__, data_map)
  end
end
