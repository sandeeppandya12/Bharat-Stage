class CreateAccountsCategoriesJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :accounts, :categories do |t|
      t.index :account_id
      t.index :category_id
    end
  end
end
