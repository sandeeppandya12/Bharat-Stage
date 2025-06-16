module BxBlockProfile
  class Associated < ApplicationRecord
    self.table_name = :bx_block_profile_associateds
# Protected Area Start
    has_many :associated_projects, class_name: "BxBlockProfile::AssociatedProject"
# Protected Area End
  end
end