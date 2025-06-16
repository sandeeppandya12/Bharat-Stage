module BxBlockChat
  class ChatMessage < BxBlockChat::ApplicationRecord
    self.table_name = :chat_messages
    include PublicActivity::Model

# Protected Area Start
    belongs_to :chat, class_name: "BxBlockChat::Chat"
    belongs_to :account, class_name: "AccountBlock::Account"
    has_many_attached :attachments, dependent: :destroy

# Protected Area End
    validates :message, presence: true

    after_create :send_push_notification

    def send_push_notification
      accounts = chat.accounts.where.not(id: account_id)
      accounts.each do |account_object|
        BxBlockPushNotifications::PushNotification.create(
          account_id: account_id,
          push_notificable: account_object,
          remarks: message
        )
      end
    end
  end
end
