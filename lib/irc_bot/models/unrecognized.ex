defmodule TwitchIrc.IrcBot.Models.Unrecognized do
  defstruct [:id, :raw_data]

  alias TwitchIrc.UUID

  def new(data_map) when is_map(data_map) do
    data_map = data_map
    |> UUID.add_id()
    struct(__MODULE__, data_map)
  end
end
