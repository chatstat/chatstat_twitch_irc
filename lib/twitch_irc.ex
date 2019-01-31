defmodule TwitchIrc do
  defmodule ExampleConsumer do
    use GenStage

    def start_link(name) do
      GenStage.start_link(__MODULE__, name)
    end

    def init(name) do
      {:ok, file} = File.open "data.bin", [:write]
      {:consumer, file, subscribe_to: [{name, max_demand: 100}]}
    end

    def handle_events(events, _from, file) do
      for event <- events do
        IO.binwrite file, inspect(event) <> "\n"
      end
      {:noreply, [], file}
    end
  end
end
