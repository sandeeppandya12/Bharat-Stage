# This migration comes from bx_block_chat (originally 20220606095230)
class RemoveColumnIsNotificationMutedFromChats < ActiveRecord::Migration[6.0]
  def change
    remove_column :chats, :is_notification_mute, :boolean, default: false
  end
end
