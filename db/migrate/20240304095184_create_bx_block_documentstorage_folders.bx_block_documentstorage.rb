# This migration comes from bx_block_documentstorage (originally 20240131063053)
class CreateBxBlockDocumentstorageFolders < ActiveRecord::Migration[6.0]
  def change 
    create_table :bx_block_documentstorage_folders do |t|
      t.integer :gallery_id
      t.string :folder_name
      t.integer :folder_type

      t.timestamps
    end
  end
end
