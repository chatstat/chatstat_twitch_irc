defmodule TwitchIrc.IrcBot.Models.Userstate do
  alias TwitchIrc.IrcBot.Models.Badges

  defstruct [:id, :badges, :color, :display_name, :emotes, :mod]

  alias TwitchIrc.UUID

  def new(data_map) when is_map(data_map) do
    data_map =
      Badges.update_map(data_map)
      |> UUID.add_id()

    struct(__MODULE__, data_map)
  end
end
