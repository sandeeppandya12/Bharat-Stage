# This migration comes from bx_block_admin (originally 20240620120643)
class AddTrackableToAdminUser < ActiveRecord::Migration[6.0]
  def change
    add_column :admin_users, :sign_in_count, :integer
    add_column :admin_users, :current_sign_in_at, :datetime
    add_column :admin_users, :last_sign_in_at, :datetime
  end
end
