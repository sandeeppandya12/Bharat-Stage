module BxBlockStripeIntegration
  class PaymentIntentSerializer
    include FastJsonapi::ObjectSerializer

    attributes :client_secret, :amount, :currency, :payable_reference
    attributes :payment_intent_id, ->(object) { object.id }
    attributes :customer_id, ->(object) { object.customer }
  end
end
