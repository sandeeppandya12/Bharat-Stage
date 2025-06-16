class CreateBxBlockProfileArtistProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :bx_block_profile_artist_profiles do |t|
      t.string :first_name
      t.string :last_name
      t.text   :description 
      t.string :languages, array: true, default: []
      t.string :portfolio_links, array: true, default: []
      t.string :social_media_links, array: true
      t.string :height
      t.integer :weight
      t.string  :location 
      t.string  :gender 
      t.string  :role
      t.string  :experience_level

      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
