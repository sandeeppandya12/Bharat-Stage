# This migration comes from bx_block_block_users (originally 20210121084344)
# Protected File
class AddAccountIdForeignKeyToBlockUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :block_users, :account_id
    add_reference :block_users, :account, foreign_key: true
  end
end
