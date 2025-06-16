class AddAttrToNotification < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :chat_notification, :boolean, default: false
  end
end
