# This migration comes from bx_block_chat (originally 20211223111529)
class AddChatTypeToChats < ActiveRecord::Migration[6.0]
  def change
    add_column :chats, :chat_type, :integer, null: false
  end
end
