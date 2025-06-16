# This migration comes from bx_block_documentstorage (originally 20240203110617)
class RemoveFieldsFromGalleryDocumentstorage < ActiveRecord::Migration[6.0]
  def change 
  	remove_column :bx_block_documentstorage_galleries, :created_at, :integer
  	remove_column :bx_block_documentstorage_galleries, :updated_at, :integer
  end
end
