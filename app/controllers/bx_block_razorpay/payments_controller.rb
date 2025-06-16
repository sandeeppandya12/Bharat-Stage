module BxBlockRazorpay
  class PaymentsController < ApplicationController
    before_action :set_razorpay_service

    def create_subscription
      auto_renew = params[:auto_renew]
      plan = BxBlockCustomUserSubs::Subscription.find(params[:id])
      plan_id = plan.razorpay_plan_id
      user = current_user

      if user.nil?
        render json: { error: 'User not found' }, status: :unauthorized
        return
      end

      razorpay_service = BxBlockRazorpay::RazorpayIntegration.new
      new_subscription = razorpay_service.create_subscription(user, plan_id, auto_renew)

      if new_subscription
        render json: { subscription_id: new_subscription.id, full_phone_number: user.full_phone_number, email: user.email, first_name: user.first_name, last_name: user.last_name, status: 'created' }    else
        render json: { error: 'Failed to create subscription' }, status: :unprocessable_entity
      end
    end

    private
    
    def set_razorpay_service
      @razorpay_service = BxBlockRazorpay::RazorpayIntegration.new
    end
  end
end