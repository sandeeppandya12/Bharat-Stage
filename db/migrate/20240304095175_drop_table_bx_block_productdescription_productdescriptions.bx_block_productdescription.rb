# This migration comes from bx_block_productdescription (originally 20230413060514)
class DropTableBxBlockProductdescriptionProductdescriptions < ActiveRecord::Migration[6.0]
  def change
    drop_table :bx_block_productdescription_productdescriptions
  end
end
