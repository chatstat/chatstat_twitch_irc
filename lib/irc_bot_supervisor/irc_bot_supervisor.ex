defmodule TwitchIrc.IrcBotSupervisor do
  use DynamicSupervisor

  alias TwitchIrc.IrcBot.Config

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def start_child(%Config{} = config) do
    spec = {TwitchIrc.IrcBot, config}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def irc_bot_list() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn({:undefined, pid, :worker, [TwitchIrc.IrcBot]}) ->
      TwitchIrc.IrcBot.irc_bot_info(pid)
    end)
  end

  def irc_bot_list_expiration() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn({:undefined, pid, :worker, [TwitchIrc.IrcBot]}) ->
      name = TwitchIrc.IrcBot.irc_bot_info(pid).name
      expiration = TwitchIrc.IrcBot.has_expired?(name)
      %{pid: pid, name: name, expiration: expiration}
    end)
  end

  def clean_expired_bots() do
    irc_bot_list_expiration()
    |> Enum.filter(fn(bot) ->
      bot.expiration
    end)
    |> Enum.map(fn(bot) ->
      Task.async(fn ->
        terminate_irc_bot(bot.pid)
      end)
    end)
    |> Enum.map(fn(task) ->
      Task.await(task)
    end)
  end

  def terminate_irc_bot(username) when is_bitstring(username) do
    TwitchIrc.IrcProducerConsumer.cancel(username)
    DynamicSupervisor.terminate_child(__MODULE__, {:via, Registry, {Registry.IrcBot, {TwitchIrc.IrcBot,username}}})
  end

  def terminate_irc_bot(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def start_children(config_list) when is_list(config_list) do
    config_list
    |> Enum.map(fn(config) ->
      Task.async(fn ->
        start_child(config)
      end)
    end)
    |> Enum.map(fn(task) ->
      Task.await(task)
    end)
  end

  def init(_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end
end