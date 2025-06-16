# This migration comes from bx_block_productdescription (originally 20221209123146)
class CreateBxBlockProductdescriptionProductdescriptions < ActiveRecord::Migration[6.0]
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

      t.timestamps
    end
  end
end
