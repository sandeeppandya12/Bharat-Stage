module BxBlockEmailNotifications
  class EmailNotification < ApplicationRecord
    self.table_name = :email_notifications
# Protected Area Start
    belongs_to :notification , class_name: 'BxBlockNotifications::Notification'
# Protected Area End
  end
end
