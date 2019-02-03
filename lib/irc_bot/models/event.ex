defmodule TwitchIrc.IrcBot.Models.Event do
  alias TwitchIrc.IrcBot.State

  @enforce_keys [:event, :server]
  defstruct [:event, :server]

  def new(event, %State{} = state, timestamp) when is_map(event) when is_integer(timestamp) do
    %__MODULE__{
      event: event,
      server: generate_server(state, event, timestamp)
    }
  end

  defp generate_server(%State{} = state, event, timestamp) when is_integer(timestamp) do
    %{
      host: state.config.server_address,
      port: state.config.port,
      nickname: state.config.nickname,
      username: state.config.username,
      user_id: state.config.user_id
    }
    |> add_timestamp(event, timestamp)
  end

  defp add_timestamp(map, event, timestamp) when is_map(map) and is_integer(timestamp) do
    with true <- Map.has_key?(event, :tmi_sent_ts) do
      map
      |> Map.put(:timestamp, event.tmi_sent_ts)
    else
      false ->
        map
        |> Map.put(:timestamp, timestamp)
    end
  end

  def get_event_module(%__MODULE__{} = event) do
    event.event.__struct__
  end
end
