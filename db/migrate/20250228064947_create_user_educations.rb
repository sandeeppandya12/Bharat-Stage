class CreateUserEducations < ActiveRecord::Migration[6.1]
  def change
    create_table :user_educations do |t|
      t.string :institute_name
      t.string :qualification 
      t.datetime :start_date 
      t.datetime  :end_date 
      t.boolean   :is_ongoing 
      t.string  :location
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
