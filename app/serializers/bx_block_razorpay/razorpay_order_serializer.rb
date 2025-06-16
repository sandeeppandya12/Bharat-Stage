module BxBlockRazorpay
  class RazorpayOrderSerializer < BuilderBase::BaseSerializer
    attributes(:key, :amount, :status, :razorpay_order_id, :receipt, :account_id, 
               :order_id, :entity, :amount_paid, :amount_due, :currency, :notes)
  end
end
