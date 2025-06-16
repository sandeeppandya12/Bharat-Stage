module BxBlockProfile
  class PublicationPatent < ApplicationRecord
    self.table_name = :bx_block_profile_publication_patents
# Protected Area Start
    belongs_to :profile, class_name: "BxBlockProfile::Profile"
# Protected Area End
  end
end