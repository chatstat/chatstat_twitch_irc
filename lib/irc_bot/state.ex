defmodule TwitchIrc.IrcBot.State do
  alias TwitchIrc.IrcBot.Config
  alias TwitchIrc.Queue

  require Logger

  defstruct config: nil,
            ex_irc_client: nil,
            queue: nil,
            pending_demand: nil,
            last_event: nil

  def new(%Config{} = config) do
    %__MODULE__{
      config: config,
      ex_irc_client: nil,
      queue: Queue.new(10_000),
      pending_demand: 0,
      last_event: Timex.now("Etc/UTC")
    }
  end

  def server_info(%__MODULE__{} = state) do
    %{
      username: state.config.username,
      user_id: state.config.user_id
    }
  end

  def set_ex_irc_client(%__MODULE__{} = state, client) do
    %{state | :ex_irc_client => client}
  end

  def add_incoming_demand(%__MODULE__{pending_demand: pending_demand} = state, incoming_demand)
      when is_integer(incoming_demand) do
    %{state | :pending_demand => pending_demand + incoming_demand}
  end

  def queue_append_silent(%__MODULE__{queue: queue} = state, event) do
    %{state | :queue => Queue.append(queue, event)}
  end

  def queue_append(%__MODULE__{queue: queue} = state, event) do
    %{state | :queue => Queue.append(queue, event), :last_event => Timex.now("Etc/UTC")}
  end

  def queue_pop(%__MODULE__{queue: queue, pending_demand: pending_demand} = state) do
    {value, queue} = Queue.pop(queue)

    case value do
      nil -> {value, %{state | :queue => queue, :pending_demand => pending_demand}}
      _ -> {value, %{state | :queue => queue, :pending_demand => pending_demand - 1}}
    end
  end

  def last_event_duration(%__MODULE__{last_event: last_event}) do
    Timex.diff(Timex.now("Etc/UTC"), last_event, :duration)
  end
end
