# This migration comes from bx_block_profile (originally 20220928122724)
class CreateUserCourseExams < ActiveRecord::Migration[6.0]
  def change
    create_table :user_course_exams do |t|
      t.integer :course_id
      t.integer :quiz_and_mock_exam_id
      t.integer :flash_card_id
      t.integer :theme_id
      t.integer :account_id
      t.integer :lesson_id
      t.integer :point, default: 0
      t.string  :exam_type

      t.timestamps
    end
  end
end
