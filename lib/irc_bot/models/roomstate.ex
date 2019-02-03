defmodule TwitchIrc.IrcBot.Models.Roomstate do
  defstruct [:id, :broadcaster_lang, :emote_only, :followers_only, :r9k, :slow, :subs_only]

  alias TwitchIrc.UUID

  def new(data_map) when is_map(data_map) do
    data_map = data_map
    |> UUID.add_id()
    struct(__MODULE__, data_map)
  end
end
