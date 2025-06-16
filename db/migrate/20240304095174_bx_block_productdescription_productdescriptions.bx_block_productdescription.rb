# This migration comes from bx_block_productdescription (originally 20230331052323)
class BxBlockProductdescriptionProductdescriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_productdescription_productdescriptions do |t|
      t.string :name
      t.string :description
      t.datetime :manufacture_date
      t.integer :availability
      t.integer :stock_qty
      t.float :price
      t.boolean :recommended
      t.boolean :on_sale
      t.decimal :sale_price
      t.integer :product_id
      
      t.timestamps
    end
  end
end

