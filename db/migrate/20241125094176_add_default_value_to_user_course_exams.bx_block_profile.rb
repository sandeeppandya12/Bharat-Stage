# This migration comes from bx_block_profile (originally 20221121150836)
class AddDefaultValueToUserCourseExams < ActiveRecord::Migration[6.0]
  def change
    change_column :user_course_exams, :status, :string, :default => "not started"
  end
end
