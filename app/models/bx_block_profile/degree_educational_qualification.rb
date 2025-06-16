module BxBlockProfile
  class DegreeEducationalQualification < ApplicationRecord
    self.table_name = :bx_block_profile_degree_educational_qualifications
# Protected Area Start
    belongs_to :degree, class_name: "BxBlockProfile::Degree"
    belongs_to :educational_qualification, class_name: "BxBlockProfile::EducationalQualification"
# Protected Area End
  end
end