class CreateAccountsSubCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts_sub_categories, id: false do |t|
      t.references :account, null: false, foreign_key: true
      t.references :sub_category, null: false, foreign_key: { to_table: :sub_categories }
    end
  end
end
