module BxBlockProfile
  class Award < ApplicationRecord
    self.table_name = :bx_block_profile_awards
# Protected Area Start
    belongs_to :profile, class_name: "BxBlockProfile::Profile"
# Protected Area End
    validates :profile_id, presence: true
  end
end
