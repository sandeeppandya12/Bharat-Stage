class CreateUserSkillSubCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :user_skill_sub_categories do |t|
      t.references :user_skill, null: false, foreign_key: true
      t.string :sub_category
      t.timestamps
    end
  end
end
