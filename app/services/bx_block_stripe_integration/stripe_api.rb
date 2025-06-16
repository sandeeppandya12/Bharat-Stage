module BxBlockStripeIntegration
  class StripeApi
    class Error < StandardError; end

    class << self
      def create_payment_intent(customer_id, amount_in_cents, currency, metadata = {})
        Stripe::PaymentIntent.create(
          customer: customer_id,
          amount: amount_in_cents,
          currency: currency,
          metadata: metadata
        )
      rescue Stripe::StripeError => e
        raise Error, e.message
      end
    end
  end
end
