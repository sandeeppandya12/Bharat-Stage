module BxBlockProfile
  class FieldStudy < ApplicationRecord
    self.table_name = :bx_block_profile_field_study
# Protected Area Start
    has_many :educational_qualification_field_studys, class_name: "BxBlockProfile::EducationalQualificationFieldStudy"
# Protected Area End
  end
end