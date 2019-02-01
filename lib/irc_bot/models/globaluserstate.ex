defmodule TwitchIrc.IrcBot.Models.Globaluserstate do
  defstruct [:badges, :color, :display_name, :emote_sets, :user_id]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
