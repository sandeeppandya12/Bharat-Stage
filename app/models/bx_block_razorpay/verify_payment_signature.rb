module BxBlockRazorpay
  class VerifyPaymentSignature < ApplicationRecord
    include Wisper::Publisher
    self.table_name = :bx_block_razorpay_verify_payment_signatures

# Protected Area Start
    belongs_to :razorpay_order, class_name: "BxBlockRazorpay::RazorpayOrder", foreign_key: :razorpay_order_id

# Protected Area End
    validates :razorpay_order_id, presence: true
    validates :razorpay_payment_id, presence: true
    validates :razorpay_signature, presence: true
  end
end