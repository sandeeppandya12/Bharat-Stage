module BxBlockRazorpay
  class VerifyPaymentSignatureSerializer < BuilderBase::BaseSerializer
    attributes(:status, :rpay_order_id, :razorpay_payment_id, :razorpay_signature)
  end
end