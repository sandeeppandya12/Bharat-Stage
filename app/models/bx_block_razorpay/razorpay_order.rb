module BxBlockRazorpay
  class RazorpayOrder < ApplicationRecord
    include Wisper::Publisher
    self.table_name = :bx_block_razorpay_razorpay_orders

# Protected Area Start
    belongs_to :customer, class_name: "AccountBlock::Account", foreign_key: :account_id
    belongs_to :order, class_name: "BxBlockShoppingCart::Order", foreign_key: :order_id
    has_one :verify_payment_signature, class_name: "BxBlockRazorpay::VerifyPaymentSignature", :dependent => :destroy

# Protected Area End
    def key
      ENV["RAZORPAY_KEY_ID"]
    end
  end
end
