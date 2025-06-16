class CreateUserSkills < ActiveRecord::Migration[6.1]
  def change
    create_table :user_skills do |t|
      t.string :experience_level
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
