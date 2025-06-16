class AddChatNotificationToSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :chat_notification, :boolean, default: true
  end
end
