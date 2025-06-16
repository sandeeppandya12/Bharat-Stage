class CreateUserLanguages < ActiveRecord::Migration[6.1]
  def change
    create_table :user_languages do |t|
      t.string :name

      t.timestamps
    end
  end
end
