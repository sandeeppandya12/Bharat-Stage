# This migration comes from bx_block_content_management (originally 20230419120850)
class CreateBxBlockContentManagementContentManagments < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_content_management_content_managments do |t|
      t.string :title
      t.text :description
      t.boolean :status
      t.float :price
      t.integer :user_type
      t.string :quantity
      t.timestamps
    end
  end
end
