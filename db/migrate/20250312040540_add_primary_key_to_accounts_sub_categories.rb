class AddPrimaryKeyToAccountsSubCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts_sub_categories, :id, :primary_key
  end
end
