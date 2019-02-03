defmodule TwitchIrc.IrcBot.Models.Globaluserstate do
  alias TwitchIrc.IrcBot.Models.Badges
  alias TwitchIrc.UUID

  defstruct [:id, :badges, :color, :display_name, :emote_sets, :user_id]

  def new(data_map) when is_map(data_map) do
    data_map = Badges.update_map(data_map)
    |> UUID.add_id()
    struct(__MODULE__, data_map)
  end
end
