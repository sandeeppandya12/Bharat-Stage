# This migration comes from bx_block_chat (originally 20210422154147)
class CreateChats < ActiveRecord::Migration[6.0]
  def change
    create_table :chats do |t|
      t.timestamps
    end
  end
end
