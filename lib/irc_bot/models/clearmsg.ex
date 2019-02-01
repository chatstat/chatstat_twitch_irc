defmodule TwitchIrc.IrcBot.Models.Clearmsg do
  defstruct [:login, :message, :target_msg_id]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
