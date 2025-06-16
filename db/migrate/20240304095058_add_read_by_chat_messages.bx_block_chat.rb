# This migration comes from bx_block_chat (originally 20221115125236)
class AddReadByChatMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :chat_messages, :read_by, :integer, array: true, default: []
  end
end
