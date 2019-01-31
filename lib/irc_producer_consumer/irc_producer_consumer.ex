defmodule TwitchIrc.IrcProducerConsumer do
  use GenStage

  alias TwitchIrc.IrcBot

  require Logger

  def start_link(_ignored) do
    GenStage.start_link(
      __MODULE__,
      :ok,
      name: __MODULE__
    )
  end

  def init(:ok) do
    {:producer_consumer, :ok, dispatcher: GenStage.BroadcastDispatcher, buffer_size: 100_000}
  end

  def subscribe(username) do
    Logger.debug("#{username} subscribed to #{__MODULE__}")
    GenStage.sync_subscribe(__MODULE__, to: IrcBot.via(username), cancel: :temporary)
  end


  def handle_events(events, _from, state) do
    {:noreply, events, state}
  end
end