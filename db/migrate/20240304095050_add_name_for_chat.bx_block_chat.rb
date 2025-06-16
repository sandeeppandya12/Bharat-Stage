# This migration comes from bx_block_chat (originally 20210422154150)
class AddNameForChat < ActiveRecord::Migration[6.0]
  def change
    add_column :chats, :name, :string, null: false, default: ""
  end
end
