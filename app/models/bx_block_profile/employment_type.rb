module BxBlockProfile
  class EmploymentType < ApplicationRecord
    self.table_name = :bx_block_profile_employment_types
# Protected Area Start
    has_many :current_status_employment_types, class_name: "BxBlockProfile::CurrentStatusEmploymentType"
    has_many :career_experience_employment_types, class_name: "BxBlockProfile::CareerExperienceEmploymentType"
# Protected Area End
  end
end