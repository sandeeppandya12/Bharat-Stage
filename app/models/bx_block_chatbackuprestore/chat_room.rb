module BxBlockChatbackuprestore
  class ChatRoom < ApplicationRecord
    self.table_name = :bx_block_chatbackuprestore_chat_rooms
# Protected Area Start
    belongs_to :account, class_name: 'AccountBlock::Account'
    has_many :chat_messages, class_name: "BxBlockChatbackuprestore::ChatMessage"
# Protected Area End
  end
end