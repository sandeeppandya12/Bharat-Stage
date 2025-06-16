# This migration comes from bx_block_chat (originally 20210422154148)
class AccountsChats < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts_chats do |t|
      t.belongs_to :account
      t.belongs_to :chat
      t.string :status
      t.timestamps
    end
  end
end
