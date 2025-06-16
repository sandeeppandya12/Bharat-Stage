# This migration comes from bx_block_chatbackuprestore (originally 20230512053833)
class CreateBxBlockChatbackuprestoreChatMessage < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_chatbackuprestore_chat_messages do |t|
      t.integer :account_id
      t.integer :chat_room_id
      t.string :message

      t.timestamps
    end
  end
end
