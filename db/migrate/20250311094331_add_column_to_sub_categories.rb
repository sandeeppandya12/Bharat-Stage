class AddColumnToSubCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :sub_categories, :experience_levels, :integer
  end
end
