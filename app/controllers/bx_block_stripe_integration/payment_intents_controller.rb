module BxBlockStripeIntegration
  class PaymentIntentsController < BxBlockStripeIntegration::ApplicationController
    def create
      return unless validate_parameters(payment_intent_params, %w[order_id])
      order_id = payment_intent_params[:order_id]
      pi_delegate = BxBlockStripeIntegration.payment_intent_delegate.create(order_id)
      payment_intent = PaymentIntent.create!(current_stripe_customer.stripe_id, order_id, pi_delegate)
      render json: PaymentIntentSerializer.new(payment_intent).serializable_hash
    rescue PayableNotFoundError
      render json: {errors: [order: "Order Not Found."]}, status: :not_found
    rescue PayablePreconditionsUnmet => e
      render json: {errors: [order: e.message]}, status: :unprocessable_entity
    rescue StripeApi::Error => e
      render json: {errors: [stripe: e.message]}, status: :unprocessable_entity
    end

    private

    def payment_intent_params
      params.require(:payment_intent).permit(:order_id)
    end
  end
end
