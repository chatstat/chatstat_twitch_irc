defmodule TwitchIrc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      TwitchIrc.IrcBotSupervisor,
      TwitchIrc.IrcProducerConsumer,
      {Registry, [keys: :unique, name: Registry.IrcBot]}
      # Starts a worker by calling: TwitchIrc.Worker.start_link(arg)
      # {TwitchIrc.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitchIrc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
