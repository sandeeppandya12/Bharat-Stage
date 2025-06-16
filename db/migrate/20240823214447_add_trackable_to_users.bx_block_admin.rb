# This migration comes from bx_block_admin (originally 20240504085817)
class AddTrackableToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :admin_users, :current_sign_in_ip, :inet
    add_column :admin_users, :last_sign_in_ip, :inet
  end
end