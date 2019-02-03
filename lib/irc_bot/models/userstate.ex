defmodule TwitchIrc.IrcBot.Models.Userstate do
  alias TwitchIrc.IrcBot.Models.Badges

  defstruct [:badges, :color, :display_name, :emotes, :mod]

  def new(data_map) when is_map(data_map) do
    data_map = Badges.update_map(data_map)
    struct(__MODULE__, data_map)
  end
end
