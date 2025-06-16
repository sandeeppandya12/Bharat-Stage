# This migration comes from bx_block_chatbackuprestore (originally 20230512053436)
class CreateBxBlockChatbackuprestoreChatRoom < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_chatbackuprestore_chat_rooms do |t|
      t.integer :account_id
      t.integer :chat_user
      t.boolean :is_permitted, default: false

      t.timestamps
    end
  end
end
