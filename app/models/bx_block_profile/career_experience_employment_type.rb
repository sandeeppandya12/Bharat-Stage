module BxBlockProfile
  class CareerExperienceEmploymentType < ApplicationRecord
    self.table_name = :bx_block_profile_career_experience_employment_types
# Protected Area Start
    belongs_to :career_experience, class_name: "BxBlockProfile::CareerExperience"
    belongs_to :employment_type, class_name: "BxBlockProfile::EmploymentType"
# Protected Area End
  end
end