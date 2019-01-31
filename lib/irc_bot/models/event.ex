defmodule TwitchIrc.IrcBot.Models.Event do

    alias TwitchIrc.IrcBot.State

    @enforce_keys [:event, :server]
    defstruct [:event, :server]

    def new(event, %State{} = state) when is_map(event) do
        %__MODULE__{
            event: event,
            server: generate_server(state)
        }
    end

    defp generate_server(%State{} = state) do
        %{
            host: state.config.server_address,
            port: state.config.port,
            nickname: state.config.nickname,
            username: state.config.username,
            user_id: state.config.user_id
        }
    end
end