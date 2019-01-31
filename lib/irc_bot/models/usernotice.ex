defmodule TwitchIrc.IrcBot.Models.Usernotice do
  defstruct [:badges, :color, :display_name, :emotes, :id, :login, :message, :mod, :msg_id, :msg_param_displayName,
            :msg_param_login, :msg_param_months, :msg_param_recipient_display_name, :msg_param_recipient_id,
            :msg_param_recipient_user_name, :msg_param_sub_plan, :msg_param_sub_plan_name, :msg_param_viewerCount,
            :msg_param_ritual_name, :room_id, :system_msg, :tmi_sent_ts, :user_id]

  def new(data_map) when is_map(data_map) do
    struct(__MODULE__, data_map)
  end
end