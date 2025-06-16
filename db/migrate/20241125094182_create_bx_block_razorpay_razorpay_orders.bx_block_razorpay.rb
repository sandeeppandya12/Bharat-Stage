# This migration comes from bx_block_razorpay (originally 20230719113427)
class CreateBxBlockRazorpayRazorpayOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_razorpay_razorpay_orders do |t|
      t.float :amount
      t.string :status
      t.string :razorpay_order_id
      t.string :receipt
      t.bigint :account_id
      t.bigint :order_id
      t.string :razorpay_payment_id
      t.string :razorpay_signature
    end
  end
end
