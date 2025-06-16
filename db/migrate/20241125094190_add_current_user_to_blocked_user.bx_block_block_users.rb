# This migration comes from bx_block_block_users (originally 20210121054344)
# Protected File
class AddCurrentUserToBlockedUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :block_users, :current_user_id
    add_reference :block_users, :current_user, foreign_key: { to_table: :accounts }
  end
end
