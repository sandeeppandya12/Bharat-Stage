class AddColumnToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :title, :string
  end
end
