# This migration comes from bx_block_profile (originally 20221121065452)
class AddStatusToUserCourseExams < ActiveRecord::Migration[6.0]
  def change
    add_column :user_course_exams, :status, :string
  end
end
