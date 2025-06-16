class CreateUserCareers < ActiveRecord::Migration[6.1]
  def change
    create_table :user_careers do |t|
      t.string :project_name
      t.string :role
      t.datetime :start_date
      t.datetime :end_date 
      t.boolean  :is_ongoing, default: false 
      t.string :location 
      t.string :project_link, array: true 
      t.text   :description
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
