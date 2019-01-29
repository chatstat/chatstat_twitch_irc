defmodule TwitchIrc do
  defmodule ExampleConsumer do
    use GenStage

    def start_link(name) do
      GenStage.start_link(__MODULE__, name)
    end

    def init(name) do
      {:consumer, name, subscribe_to: [{name, max_demand: 100}]}
    end

    def handle_events(events, _from, state) do
      for event <- events do
        IO.inspect(event)
      end
      {:noreply, [], state}
    end
  end
end
