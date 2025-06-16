# This migration comes from bx_block_profile (originally 20230320104413)
class AddQuizAndAnswerPollingIdToUserCourseExam < ActiveRecord::Migration[6.0]
  def change
    add_column :user_course_exams, :quiz_and_answer_polling_id, :integer
  end
end
