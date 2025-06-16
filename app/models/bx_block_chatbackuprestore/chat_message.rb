module BxBlockChatbackuprestore
  class ChatMessage < ApplicationRecord
    self.table_name = :bx_block_chatbackuprestore_chat_messages
# Protected Area Start
    belongs_to :account, class_name: 'AccountBlock::Account'
    belongs_to :chat_rooms, class_name: 'BxBlockChatbackuprestore::ChatRoom', foreign_key: 'chat_room_id'
# Protected Area End
  end
end