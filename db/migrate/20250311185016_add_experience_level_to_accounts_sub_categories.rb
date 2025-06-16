class AddExperienceLevelToAccountsSubCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts_sub_categories, :experience_level, :integer, default: 0
  end
end
