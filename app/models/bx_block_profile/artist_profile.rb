module BxBlockProfile
  class ArtistProfile < ApplicationRecord
    has_one_attached :profile_picture 
    has_one_attached :cover_photo
    self.table_name = :bx_block_profile_artist_profiles
    belongs_to :account, class_name: "AccountBlock::Account"

    scope :search_by_name, ->(name) {
      where(
        "LOWER(first_name) LIKE :name_start OR LOWER(last_name) LIKE :name_start OR LOWER(CONCAT(first_name, ' ', last_name)) LIKE :name_start",
        name_start: "#{name.downcase}%"
      )
    }
  end
end
