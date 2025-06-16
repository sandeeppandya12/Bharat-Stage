module BxBlockProfile
  class Industry < ApplicationRecord
    self.table_name = :bx_block_profile_industries
# Protected Area Start
    has_many :current_status_industrys, class_name: "BxBlockProfile::CurrentStatusIndustry"
    has_many :career_experience_industrys, class_name: "BxBlockProfile::CareerExperienceIndustry"
# Protected Area End
  end
end