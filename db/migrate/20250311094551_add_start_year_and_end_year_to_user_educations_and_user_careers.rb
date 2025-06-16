class AddStartYearAndEndYearToUserEducationsAndUserCareers < ActiveRecord::Migration[6.1]
  def change
    add_column :user_educations, :start_year, :integer
    add_column :user_educations, :end_year, :integer
    
    add_column :user_careers, :start_year, :integer
    add_column :user_careers, :end_year, :integer
  end
end
