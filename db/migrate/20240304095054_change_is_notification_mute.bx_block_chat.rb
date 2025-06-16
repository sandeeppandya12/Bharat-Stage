# This migration comes from bx_block_chat (originally 20220503113134)
class ChangeIsNotificationMute < ActiveRecord::Migration[6.0]
  def change
    change_column :chats, :is_notification_mute, :boolean, default: false
  end
end
