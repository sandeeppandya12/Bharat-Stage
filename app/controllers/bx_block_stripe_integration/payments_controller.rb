module BxBlockStripeIntegration
  class PaymentsController < BxBlockStripeIntegration::ApplicationController
    def confirm
      return unless validate_parameters(payment_params, %w[payment_method_id payment_intent_id])

      unless current_stripe_customer.stripe_id.present?
        render json: {
          error: "Customer stripe id is not found"
        }, status: :not_found and return
      end

      begin
        stripe_payment_intent = Stripe::PaymentIntent.confirm(
          payment_params[:payment_intent_id],
          {
            payment_method: payment_params[:payment_method_id],
            receipt_email: current_user.email
          }
        )
        render json: PaymentIntentSerializer.new(PaymentIntent.from_stripe_payment_intent(stripe_payment_intent)).serializable_hash
      rescue Stripe::StripeError => e
        render json: {
          errors: [{stripe: e.message}]
        }, status: :unprocessable_entity
      end
    end

    private

    def payment_params
      params.require(:payment).permit(:order_id, :payment_method_id, :payment_intent_id)
    end
  end
end
