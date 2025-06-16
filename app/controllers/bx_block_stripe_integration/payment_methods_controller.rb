module BxBlockStripeIntegration
  class PaymentMethodsController < BxBlockStripeIntegration::ApplicationController
    def index
      stripe_payment_methods = Stripe::PaymentMethod.list(customer: current_stripe_customer.stripe_id, type: "card")
      payment_methods = []
      stripe_payment_methods.each do |stripe_pm|
        payment_methods << PaymentMethod.new(stripe_pm)
      end
      render json: PaymentMethodSerializer.new(payment_methods).serializable_hash
    rescue Stripe::StripeError => e
      render json: {
        errors: [{stripe: e.message}]
      }, status: :unprocessable_entity
    end

    def create
      valid, result = CreatePaymentMethod.new(payment_method_params.to_h).call

      if valid
        valid, result = AttachPaymentMethod.new(current_stripe_customer.stripe_id, result.id).call
        if valid
          render json: PaymentMethodSerializer.new(PaymentMethod.new(result)).serializable_hash
        else
          render json: {
            errors: [{stripe: result}]
          }, status: :unprocessable_entity
        end
      else
        render json: {
          errors: [{stripe: result}]
        }, status: :unprocessable_entity
      end
    end

    private

    def payment_method_params
      params.require(:payment_method).permit(:number, :exp_month, :exp_year, :cvc)
    end
  end
end
