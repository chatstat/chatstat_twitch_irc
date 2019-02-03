defmodule TwitchIrc.IrcBot do
  use GenStage
  require Logger

  alias TwitchIrc.IrcBot.Config
  alias TwitchIrc.IrcBot.State
  alias TwitchIrc.IrcProducerConsumer
  alias TwitchIrc.IrcBot.Parser
  alias TwitchIrc.IrcBot.Models.Event
  alias TwitchIrc.IrcBot.Models

  def start_link(%Config{} = config) do
    GenStage.start_link(
      __MODULE__,
      State.new(config),
      name: via(config)
    )
  end

  def via(username) when is_bitstring(username) do
    {:via, Registry, {Registry.IrcBot, {__MODULE__, username}}}
  end

  def via(%Config{} = config) do
    {:via, Registry, {Registry.IrcBot, {__MODULE__, config.username}}}
  end

  def init(%State{} = state) do
    case ExIRC.start_link!() do
      {:ok, client} ->
        Logger.debug("Successfully started ExIRC client")
        ExIRC.Client.add_handler(client, self())
        :ok = ExIRC.Client.connect_ssl!(client, state.config.server_address, state.config.port)

        IrcProducerConsumer.subscribe(state.config.username)

        {:producer, State.set_ex_irc_client(state, client), dispatcher: GenStage.BroadcastDispatcher}

      {:error, error} ->
        Logger.debug("Failed to start ExIRC client", error: error)
        {:stop, error}
    end
  end

  def irc_bot_info(pid) do
    case Registry.keys(Registry.IrcBot, pid) do
      [key] ->
        %{
          name: key,
          info: Process.info(pid)
        }

      [] ->
        :error
    end
  end

  def terminate(_reason, state) do
    ExIRC.Client.stop!(state.ex_irc_client)
  end

  def stop_server(username) when is_bitstring(username) do
    GenServer.call(via(username), :stop_server)
  end

  def stop_server(pid) do
    GenServer.call(pid, :stop_server)
  end

  def last_event_duration(username) when is_bitstring(username) do
    GenServer.call(via(username), :last_event_duration)
  end

  def last_event_duration(pid) do
    GenServer.call(pid, :last_event_duration)
  end

  def has_expired?(username) when is_bitstring(username) do
    GenServer.call(via(username), :has_expired)
  end

  def has_expired?(pid) do
    GenServer.call(pid, :has_expired)
  end

  def handle_call(:stop_server, _from, %State{} = state) do
    {:stop, nil, :shutdown, state}
  end

  def handle_call(:last_event_duration, _from, %State{} = state) do
    {:reply, State.last_event_duration(state), [], state}
  end

  def handle_call(:has_expired, _from, %State{} = state) do
    timestamp = :os.system_time(:milli_seconds)
    last_event_duration_seconds = Timex.Duration.to_seconds(State.last_event_duration(state))

    cond do
      last_event_duration_seconds >= state.config.timeout ->
        dispatch_events_reply(
          true,
          State.queue_append_silent(state, Event.new(%Models.HasExpired{expired: true}, state, timestamp)),
          []
        )

      last_event_duration_seconds < state.config.timeout ->
        dispatch_events_reply(
          false,
          State.queue_append_silent(state, Event.new(%Models.HasExpired{expired: false}, state, timestamp)),
          []
        )
    end
  end

  def handle_info({:connected, server_address, port}, %State{} = state) do
    timestamp = :os.system_time(:milli_seconds)
    Logger.debug("Connected to #{server_address}:#{port}")
    Logger.debug("Logging to #{server_address}:#{port} as #{state.config.nickname}..")

    case ExIRC.Client.logon(
           state.ex_irc_client,
           generate_password(state.config),
           state.config.nickname,
           state.config.nickname,
           state.config.nickname
         ) do
      :ok ->
        dispatch_events(State.queue_append(state, Event.new(Models.Connected.new(), state, timestamp)), [])

      {:error, error} ->
        {:stop, error, state}
    end
  end

  def handle_info(:disconnected, %State{} = state) do
    timestamp = :os.system_time(:milli_seconds)
    Logger.debug("Disconnected from #{state.config.server_address}:#{state.config.port}")
    ExIRC.Client.stop!(state.ex_irc_client)
    dispatch_events(State.queue_append(state, Event.new(Models.Disconnected.new(), state, timestamp)), [])
  end

  def handle_info(:logged_in, %State{} = state) do
    timestamp = :os.system_time(:milli_seconds)
    channel_name = generate_channel_name(state.config)

    Logger.debug("Logged in to #{state.config.server_address}:#{state.config.port}")
    Logger.debug("Joining #{channel_name}..")

    ExIRC.Client.join(state.ex_irc_client, channel_name)
    dispatch_events(State.queue_append(state, Event.new(Models.LoggedIn.new(), state, timestamp)), [])
  end

  def handle_info({:joined, channel}, %State{} = state) do
    timestamp = :os.system_time(:milli_seconds)
    Logger.debug("Joined channel #{channel}")

    with :ok <- ExIRC.Client.cmd(state.ex_irc_client, "CAP REQ :twitch.tv/tags"),
         :ok <- ExIRC.Client.cmd(state.ex_irc_client, "CAP REQ :twitch.tv/membership"),
         :ok <- ExIRC.Client.cmd(state.ex_irc_client, "CAP REQ :twitch.tv/commands") do
      dispatch_events(State.queue_append(state, Event.new(Models.Joined.new(), state, timestamp)), [])
    else
      {:error, error} -> {:stop, error, state}
    end
  end

  def handle_info(message, %State{} = state) do
    timestamp = :os.system_time(:milli_seconds)
    dispatch_events(State.queue_append(state, Event.new(Parser.parse(message), state, timestamp)), [])
  end

  def handle_demand(incoming_demand, %State{} = state) do
    dispatch_events(State.add_incoming_demand(state, incoming_demand), [])
  end

  def dispatch_events_reply(reply, %State{pending_demand: 0} = state, events) do
    {:reply, reply, events, state}
  end

  def dispatch_events_reply(reply, %State{} = state, events) do
    case State.queue_pop(state) do
      {nil, state} ->
        {:reply, reply, events, state}

      {event, state} ->
        dispatch_events_reply(reply, state, [event | events])
    end
  end

  def dispatch_events(%State{pending_demand: 0} = state, events) do
    {:noreply, events, state}
  end

  def dispatch_events(%State{} = state, events) do
    case State.queue_pop(state) do
      {nil, state} ->
        {:noreply, events, state}

      {event, state} ->
        dispatch_events(state, [event | events])
    end
  end

  def generate_name(%Config{} = config) do
    String.to_atom("twitch_bot_" <> config.username)
  end

  def generate_name(username) when is_bitstring(username) do
    String.to_atom("twitch_bot_" <> username)
  end

  defp generate_channel_name(%Config{} = config) do
    "##{String.downcase(config.username)}"
  end

  defp generate_password(%Config{} = config) do
    "oauth:#{config.oauth_token}"
  end
end
