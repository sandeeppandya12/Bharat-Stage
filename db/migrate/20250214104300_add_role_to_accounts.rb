class AddRoleToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :roles, :string, default: 'artist'
  end
end



