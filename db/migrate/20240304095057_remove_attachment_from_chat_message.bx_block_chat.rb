# This migration comes from bx_block_chat (originally 20221031072022)
class RemoveAttachmentFromChatMessage < ActiveRecord::Migration[6.0]
  def change
    remove_column :chat_messages, :attachment, :string
  end
end
