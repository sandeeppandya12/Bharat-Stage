module BxBlockProfile
  class CareerExperienceIndustry < ApplicationRecord
    self.table_name = :bx_block_profile_career_experience_industry
# Protected Area Start
    belongs_to :career_experience, class_name: "BxBlockProfile::CareerExperience"
    belongs_to :industry, class_name: "BxBlockProfile::Industry"
# Protected Area End
  end
end