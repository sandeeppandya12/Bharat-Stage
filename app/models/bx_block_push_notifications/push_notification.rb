module BxBlockPushNotifications
  class PushNotification < ApplicationRecord
    require 'fcmpush'
    self.table_name = :push_notifications

# Protected Area Start
    belongs_to :push_notificable, polymorphic: true
    belongs_to :account, class_name: "AccountBlock::Account"
# Protected Area End
    validates :remarks, presence:true
    before_create :send_push_notification

    def send_push_notification
      if push_notificable.activated && push_notificable.device_id
        client = Fcmpush.new(ENV['FCM_PROJECT_ID'])
        payload = {
          message: {
            token: push_notificable.device_id,
            data: {
              message: remarks,
              account_id: account_id.to_s
            },
            notification: {
              body: remarks,
            },
            android: {
              priority: 'high',
              notification: {
                body: remarks,
                sound: 'default'
              }
            }
          }
        }
        client.push(payload)
      end
    rescue Exception => e
      e
    end
  end
end
