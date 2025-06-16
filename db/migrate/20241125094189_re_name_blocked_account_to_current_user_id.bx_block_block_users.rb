# This migration comes from bx_block_block_users (originally 20201120055415)
# Protected File
class ReNameBlockedAccountToCurrentUserId < ActiveRecord::Migration[6.0]
  def change
    rename_column :block_users, :blocked_account, :current_user_id
  end
end
