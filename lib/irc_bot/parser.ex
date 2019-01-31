defmodule TwitchIrc.IrcBot.Parser do

  alias TwitchIrc.IrcBot.Models

  require Logger

  def parse({:unrecognized, raw_command, %ExIRC.Message{args: raw_args}} = raw_data) do
    args = parse_raw_args(raw_args)

    if Map.has_key?(args, :command) do
      case args.command do
        :CLEARCHAT ->
          raw_command_to_map(raw_command)
          |> Map.put(:user, Map.get(args, :extra, ""))
          |> Models.Clearchat.new()
        :CLEARMSG ->
          raw_command_to_map(raw_command)
          |> Map.put(:message, Map.get(args, :extra, ""))
          |> Models.Clearmsg.new()
        :GLOBALUSERSTATE ->
          raw_command_to_map(raw_command)
          |> Models.Globaluserstate.new()
        :PRIVMSG ->
          raw_command_to_map(raw_command)
          |> Map.put(:message, Map.get(args, :extra, ""))
          |> Models.Privmsg.new()
        :ROOMSTATE ->
          raw_command_to_map(raw_command)
          |> Models.Roomstate.new()
        :USERNOTICE ->
          raw_command_to_map(raw_command)
          |> Map.put(:message, Map.get(args, :extra, ""))
          |> Models.Usernotice.new()
        :NOTICE ->
          raw_command_to_map(raw_command)
          |> Map.put(:message, Map.get(args, :extra, ""))
          |> Models.Notice.new()
        :USERSTATE ->
          raw_command_to_map(USERSTATE)
          |> Models.Userstate.new()
      end
    else
      Logger.debug("Unrecognized message: #{inspect(raw_data)}")
      Models.Unrecognized.new(%{raw_data: raw_data})
    end
  end

  def parse({:parted, channel, %ExIRC.SenderInfo{host: host, nick: nickname, user: username}}) do
    Models.UserParted.new(%{channel: channel, host: host, nickname: nickname, username: username})
  end

  def parse({:joined, channel, %ExIRC.SenderInfo{host: host, nick: nickname, user: username}}) do
    Models.UserJoined.new(%{channel: channel, host: host, nickname: nickname, username: username})
  end

  def parse({:disconnected}) do
    Models.Disconnected.new()
  end

  def parse(raw_data) do
    Logger.debug("Unrecognized message: #{inspect(raw_data)}")
    Models.Unrecognized.new(%{raw_data: raw_data})
  end

  defp clean_raw_command("@" <> raw_command) when is_bitstring(raw_command) do
    raw_command
  end

  def raw_command_to_map(raw_command) when is_bitstring(raw_command) do
    raw_command
    |> clean_raw_command()
    |> String.split(";")
    |> Enum.reduce(%{}, fn(data, map) ->
      data = data
      |> String.split("=")

      key = Enum.at(data, 0)
      |> String.replace("-", "_")
      |> String.to_atom()

      value = Enum.at(data, 1)

      Map.put(map, key, value)
    end)
  end

  def parse_raw_args(raw_args) when is_list(raw_args) do
    parse_raw_args(Enum.at(raw_args, 0))
  end

  def parse_raw_args(raw_args) when is_bitstring(raw_args) do
    raw_args
    |> String.split(" ", parts: 4)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn({arg, index}, map) ->
      case index do
        0 -> Map.put(map, :host, arg)
        1 -> Map.put(map, :command, parse_command(arg))
        2 -> Map.put(map, :channel, parse_channel(arg))
        3 -> Map.put(map, :extra, parse_extra(arg))
      end
    end)
  end

  defp parse_channel(arg) when is_bitstring(arg) do
    Enum.at(String.split(arg, "#"), 1)
  end

  def parse_command(arg) when is_bitstring(arg) do
    String.to_atom(arg)
  end

  def parse_extra(":" <> arg) do
    arg
  end
end