# This migration comes from bx_block_razorpay (originally 20230721112610)
class AddMoreColInRazorpayOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :bx_block_razorpay_razorpay_orders, :entity, :string
    add_column :bx_block_razorpay_razorpay_orders, :amount_paid, :decimal
    add_column :bx_block_razorpay_razorpay_orders, :amount_due, :decimal
    add_column :bx_block_razorpay_razorpay_orders, :currency, :string
    add_column :bx_block_razorpay_razorpay_orders, :offer_id, :string
    add_column :bx_block_razorpay_razorpay_orders, :attempts, :bigint
    add_column :bx_block_razorpay_razorpay_orders, :notes, :json
    remove_column :bx_block_razorpay_razorpay_orders, :razorpay_payment_id
    remove_column :bx_block_razorpay_razorpay_orders, :razorpay_signature
    
    add_index :bx_block_razorpay_razorpay_orders, :razorpay_order_id
    add_index :bx_block_razorpay_razorpay_orders, :order_id
    add_index :bx_block_razorpay_razorpay_orders, :account_id
    add_index :bx_block_razorpay_razorpay_orders, :status
  end
end
