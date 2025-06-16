# This migration comes from bx_block_chat (originally 20220606095404)
class AddColumnMutedToAccountChats < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts_chats, :muted, :boolean, default: false
  end
end
