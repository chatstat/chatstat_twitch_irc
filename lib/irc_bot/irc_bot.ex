defmodule TwitchIrc.IrcBot do
  use GenStage
  require Logger
  alias TwitchIrc.IrcBot.Config
  alias TwitchIrc.IrcBot.State

  def start_link(%Config{} = config) do
    GenStage.start_link(
      __MODULE__,
      State.new(config),
      name: generate_name(config)
    )
  end

  def init(%State{} = state) do
    case ExIRC.start_link!() do
      {:ok, client} ->
        Logger.debug("Successfully started ExIRC supervisor")
        ExIRC.Client.add_handler(client, self())
        ExIRC.Client.connect_ssl!(client, state.config.server_address, state.config.port)

        {:producer, State.set_ex_irc_client(state, client), dispatcher: GenStage.BroadcastDispatcher}

      {:error, error} ->
        Logger.debug("Failed to start ExIRC supervisor", [error: error])
        {:stop, error}
    end
  end

  def terminate(_reason, state) do
    ExIRC.Client.stop!(state.ex_irc_client)
  end

  def stop_server(username) when is_bitstring(username) do
    GenServer.call(generate_name(username), :stop_server)
  end

  def stop_server(pid) do
    GenServer.call(pid, :stop_server)
  end

  def last_event_duration(username) when is_bitstring(username) do
    GenServer.call(generate_name(username), :last_event_duration)
  end

  def last_event_duration(pid) do
    GenServer.call(pid, :last_event_duration)
  end

  def handle_call(:stop_server, _from, %State{} = state) do
    {:stop, nil, :ok, state}
  end

  def handle_call(:last_event_duration, _from, %State{} = state) do
    {:reply, State.last_event_duration(state), [], state}
  end

  def handle_info({:connected, server_address, port}, %State{} = state) do
    Logger.debug("Connected to #{server_address}:#{port}")
    Logger.debug("Logging to #{server_address}:#{port} as #{state.config.nickname}..")

    case ExIRC.Client.logon(state.ex_irc_client,
      generate_password(state.config),
      state.config.nickname,
      state.config.nickname,
      state.config.nickname
    ) do
      :ok -> dispatch_events(State.queue_append(state, {:connected, server_address, port}), [])
      {:error, error} -> {:stop, error, state}
    end

  end

  def handle_info(:logged_in, %State{} = state) do
    channel_name = generate_channel_name(state.config)

    Logger.debug("Logged in to #{state.config.server_address}:#{state.config.port}")
    Logger.debug("Joining #{channel_name}..")

    ExIRC.Client.join(state.ex_irc_client, channel_name)
    dispatch_events(State.queue_append(state, {:logged_in, state.config.server_address, state.config.port}), [])
  end

  def handle_info({:joined, channel}, %State{} = state) do
    Logger.debug("Joined channel #{channel}")

    with :ok <- ExIRC.Client.cmd(state.ex_irc_client, "CAP REQ :twitch.tv/tags")do
      dispatch_events(State.queue_append(state, {:joined, channel}), [])
    else
      {:error, error} -> {:stop, error, state}
    end
  end

  def handle_info(message, %State{} = state) do
    dispatch_events(State.queue_append(state, {:message, message}), [])
  end

  def handle_demand(incoming_demand, %State{} = state) do
    dispatch_events(State.add_incoming_demand(state, incoming_demand), [])
  end

  def dispatch_events(%State{pending_demand: 0} = state, events) do
    {:noreply, events, state}
  end

  def dispatch_events(%State{} = state, events) do
    case State.queue_pop(state) do
      {nil, state} ->
        IO.puts("No events left")
        {:noreply, events, state}
      {event, state} ->
        dispatch_events(state, [event | events])
    end
  end

  defp generate_name(%Config{} = config) do
    String.to_atom("twitch_bot_" <> config.username)
  end

  defp generate_name(username) when is_bitstring(username) do
    String.to_atom("twitch_bot_" <> username)
  end

  defp generate_channel_name(%Config{} = config) do
    "##{config.username}"
  end

  defp generate_password(%Config{} = config) do
    "oauth:#{config.oauth_token}"
  end
end
