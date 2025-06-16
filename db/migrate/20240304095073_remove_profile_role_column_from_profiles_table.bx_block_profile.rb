# This migration comes from bx_block_profile (originally 20230105072402)
class RemoveProfileRoleColumnFromProfilesTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :profiles, :profile_role, :integer
  end
end
