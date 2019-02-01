defmodule TwitchIrc.IrcBot.Models.Roomstate do
  defstruct [:broadcaster_lang, :emote_only, :followers_only, :r9k, :slow, :subs_only]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end
