# This migration comes from bx_block_chat (originally 20210423130315)
class AddIsMarkReadToChatMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :chat_messages, :is_mark_read, :boolean, default: false
    add_column :chat_messages, :message_type, :integer
    add_column :chat_messages, :attachment, :string
  end
end
