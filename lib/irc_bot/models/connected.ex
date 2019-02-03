defmodule TwitchIrc.IrcBot.Models.Connected do
  defstruct [:id]

  alias TwitchIrc.UUID

  def new() do
    struct(__MODULE__, UUID.empty_id_map())
  end
end
