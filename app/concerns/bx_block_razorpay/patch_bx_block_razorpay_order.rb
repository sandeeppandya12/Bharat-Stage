module BxBlockRazorpay
  module PatchBxBlockRazorpayOrder
    extend ActiveSupport::Concern

    included do
      has_one :razorpay_order, class_name: "BxBlockRazorpay::RazorpayOrder", foreign_key: :order_id
    end
  end
end
