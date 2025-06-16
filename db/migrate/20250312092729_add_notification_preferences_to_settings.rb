class AddNotificationPreferencesToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :email_notification, :boolean, default: true, null: false
    add_column :settings, :in_app_notification, :boolean, default: true, null: false
    add_column :settings, :desktop_notification, :boolean, default: true, null: false
  end
end
