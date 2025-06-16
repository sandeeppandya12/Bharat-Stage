class AddLocationsToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :locations, :string
  end
end
