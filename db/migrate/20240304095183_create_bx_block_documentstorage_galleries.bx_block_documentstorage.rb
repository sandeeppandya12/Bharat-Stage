# This migration comes from bx_block_documentstorage (originally 20240131062847)
class CreateBxBlockDocumentstorageGalleries < ActiveRecord::Migration[6.0]
  def change 
    create_table :bx_block_documentstorage_galleries do |t|
      t.integer :gallery_type
      t.integer :account_id

      t.timestamps
    end
  end
end
