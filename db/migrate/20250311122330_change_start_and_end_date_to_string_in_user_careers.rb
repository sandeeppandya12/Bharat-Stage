class ChangeStartAndEndDateToStringInUserCareers < ActiveRecord::Migration[6.1]
  def up
    change_column :user_careers, :start_date, :string
    change_column :user_careers, :end_date, :string
    change_column :user_educations, :start_date, :string
    change_column :user_educations, :end_date, :string
  end
end
