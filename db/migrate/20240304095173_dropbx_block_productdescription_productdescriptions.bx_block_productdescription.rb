# This migration comes from bx_block_productdescription (originally 20230331051251)
class DropbxBlockProductdescriptionProductdescriptions < ActiveRecord::Migration[6.0]
  def change
        drop_table :bx_block_productdescription_productdescriptions
  end
end
