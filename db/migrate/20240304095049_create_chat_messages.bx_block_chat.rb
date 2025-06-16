# This migration comes from bx_block_chat (originally 20210422154149)
class CreateChatMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :chat_messages do |t|
      t.references :account, foreign_key: true, index: true
      t.references :chat, foreign_key: true, index: true
      t.string :message, null: false
      t.timestamps
    end
  end
end
