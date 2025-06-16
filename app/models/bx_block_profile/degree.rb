module BxBlockProfile
  class Degree < ApplicationRecord
    self.table_name = :bx_block_profile_degrees
# Protected Area Start
    has_many  :degree_educational_qualifications,
              class_name: "BxBlockProfile::DegreeEducationalQualification"
# Protected Area End
  end
end