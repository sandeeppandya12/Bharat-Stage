module BxBlockProfile
  class EducationalQualification < ApplicationRecord
    self.table_name = :bx_block_profile_educational_qualifications
# Protected Area Start
    belongs_to :profile, class_name: "BxBlockProfile::Profile"
    has_many :degree_educational_qualifications, class_name: "BxBlockProfile::DegreeEducationalQualification"
    has_many :educational_qualification_field_studys, class_name: "BxBlockProfile::EducationalQualificationFieldStudy"
# Protected Area End
  end
end