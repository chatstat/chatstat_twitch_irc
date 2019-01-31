defmodule TwitchIrc.IrcBot.Models.Privmsg do
  defstruct [:badges, :bits, :color, :display_name, :emotes, :id, :message, :mod, :room_id, :tmi_sent_ts, :user_id]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end