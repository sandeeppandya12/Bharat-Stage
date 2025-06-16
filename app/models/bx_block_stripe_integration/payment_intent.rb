module BxBlockStripeIntegration
  class PaymentIntent
    attr_accessor :id, :amount, :client_secret, :currency, :customer, :payable_reference

    class << self
      def from_stripe_payment_intent(stripe_payment_intent)
        new.tap do |pi|
          pi.id = stripe_payment_intent[:id]
          pi.amount = stripe_payment_intent[:amount]
          pi.client_secret = stripe_payment_intent[:client_secret]
          pi.currency = stripe_payment_intent[:currency]
          pi.customer = stripe_payment_intent[:customer]
        end
      end

      def create!(customer_id, payable_reference, pi_delegate)
        metadata = {
          payable_reference: payable_reference
        }

        stripe_payment_intent = BxBlockStripeIntegration::StripeApi.create_payment_intent(
          customer_id,
          pi_delegate.amount_in_cents,
          pi_delegate.currency,
          metadata
        )

        from_stripe_payment_intent(stripe_payment_intent).tap do |pi|
          pi.payable_reference = payable_reference
        end
      end
    end
  end
end
