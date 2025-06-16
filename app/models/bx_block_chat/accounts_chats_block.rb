module BxBlockChat
  class AccountsChatsBlock < BxBlockChat::ApplicationRecord
    self.table_name = :accounts_chats
# Protected Area Start
    belongs_to :chat, class_name: "BxBlockChat::Chat"
    belongs_to :account, class_name: "AccountBlock::Account"

# Protected Area End
    after_save :update_chat_for_type

    validates :chat_id, uniqueness: {scope: :account_id,
                                     message: "should added only one time on same chat"}

    def update_chat_for_type
      chat.update(chat_type: "multiple_user") if chat.accounts.count > 2
    end
  end
end
