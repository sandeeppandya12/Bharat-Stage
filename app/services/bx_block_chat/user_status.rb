module BxBlockChat
  class UserStatus
    def initialize(account_id)
      @account_id = account_id
    end

    def call
      users_chats_ids = BxBlockChat::AccountsChatsBlock.where(account_id: @account_id).pluck(:chat_id)
      chats = BxBlockChat::Chat.where(id: users_chats_ids)
      ChatChannel.user_status_update(chats, @account_id)
    end
  end
end
