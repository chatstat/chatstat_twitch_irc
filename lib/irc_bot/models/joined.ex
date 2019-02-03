defmodule TwitchIrc.IrcBot.Models.Joined do
  defstruct [:id]

  alias TwitchIrc.UUID

  def new() do
    struct(__MODULE__, UUID.empty_id_map())
  end
end
