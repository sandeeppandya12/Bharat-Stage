module BxBlockProfile
  class TestScoreAndCourse < ApplicationRecord
    self.table_name = :bx_block_profile_test_score_and_courses
# Protected Area Start
    belongs_to :profile, class_name: "BxBlockProfile::Profile"
# Protected Area End
    validates :profile_id, presence: true
  end
end
