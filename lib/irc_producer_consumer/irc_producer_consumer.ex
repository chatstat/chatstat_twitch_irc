defmodule TwitchIrc.IrcProducerConsumer do
  use GenStage

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
    GenStage.sync_subscribe(__MODULE__, to: {:via, Registry, {Registry.IrcBot, {TwitchIrc.IrcBot,username}}})
  end

  def cancel(username) do
    GenStage.cancel(__MODULE__, {:via, Registry, {Registry.IrcBot, {TwitchIrc.IrcBot,username}}})
  end

  def handle_events(events, _from, number) do
    {:noreply, events, number}
  end
end