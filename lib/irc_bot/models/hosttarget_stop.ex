defmodule TwitchIrc.IrcBot.Models.HosttargetStop do
  defstruct [:id, :viewers]

  alias TwitchIrc.UUID

  def new(data_map) when is_map(data_map) do
    data_map =
      data_map
      |> UUID.add_id()

    struct(__MODULE__, data_map)
  end
end
