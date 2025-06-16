module BxBlockProfile
  class Hobby < ApplicationRecord
    self.table_name = :bx_block_profile_hobbies_and_interests
# Protected Area Start
    belongs_to :profile, class_name: "BxBlockProfile::Profile"
# Protected Area End
    validates :profile_id, presence: true
  end
end
