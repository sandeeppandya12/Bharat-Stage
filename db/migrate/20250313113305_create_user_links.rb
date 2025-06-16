class CreateUserLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :user_links do |t|
      t.references :account, null: false, foreign_key: true
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
