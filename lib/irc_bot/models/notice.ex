defmodule TwitchIrc.IrcBot.Models.Notice do
  defstruct [:msg_id, :message]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end