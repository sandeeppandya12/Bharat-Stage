class AddAgeToArtistProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :bx_block_profile_artist_profiles, :age, :integer
  end
end
