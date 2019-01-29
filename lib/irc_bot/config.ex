defmodule TwitchIrc.IrcBot.Config do
  @server_address Application.get_env(:twitch_irc, :server_adress)
  @port Application.get_env(:twitch_irc, :port)

  @derive {Inspect,
           only: [
             :server_address,
             :port,
             :nickname,
             :username,
             :user_id,
             :timeout
           ]}

  @enforce_keys [
    :server_address,
    :port,
    :nickname,
    :username,
    :user_id,
    :oauth_token,
    :timeout
  ]

  defstruct server_address: @server_address,
            port: @port,
            nickname: nil,
            username: nil,
            user_id: nil,
            oauth_token: nil,
            timeout: 120 * 60

  def new(nickname, username, user_id, oauth_token, timeout \\ 120 * 60)
      when is_bitstring(nickname) and is_bitstring(username) and is_integer(user_id) and is_bitstring(oauth_token) and
             is_integer(timeout) do
    %__MODULE__{
      server_address: @server_address,
      port: @port,
      nickname: nickname,
      username: username,
      user_id: user_id,
      oauth_token: oauth_token,
      timeout: timeout
    }
  end
end
