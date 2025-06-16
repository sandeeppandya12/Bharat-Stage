module BxBlockProfile
  class SystemExperience < ApplicationRecord
    self.table_name = :bx_block_profile_system_experiences
# Protected Area Start
    has_many :career_experience_system_experiences, class_name: "BxBlockProfile::CareerExperienceSystemExperience"
# Protected Area End
  end
end
