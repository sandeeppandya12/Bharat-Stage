# This migration comes from bx_block_razorpay (originally 20230725060923)
class CreateBxBlockRazorpayVerifyPaymentSignatures < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_razorpay_verify_payment_signatures do |t|
      t.bigint :razorpay_order_id
      t.string :rpay_order_id
      t.string :razorpay_payment_id
      t.string :razorpay_signature
      t.boolean :status, default: false

      t.timestamps

      t.index :rpay_order_id, name: 'rpay_order_id_to_vps'
      t.index :razorpay_order_id, name: 'razorpay_order_id_to_vps'
      t.index :razorpay_payment_id, name: 'razorpay_payment_id_to_vps'
    end
  end
end
