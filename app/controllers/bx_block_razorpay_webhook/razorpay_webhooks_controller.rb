module BxBlockRazorpayWebhook
	class RazorpayWebhooksController < ApplicationController  
    require 'razorpay'
  
    def receive
      payload = request.body.read
      signature = request.headers['X-Razorpay-Signature']
      secret = ENV['RAZORPAY_WEBHOOK_SECRET'] 
  
      unless verify_signature(payload, signature, secret)
        render json: { error: "Invalid webhook signature" }, status: :unauthorized
        return
      end
  
      event = JSON.parse(payload)
      case event["event"]
      when "subscription.activated"
        handle_subscription_activated(event)
      when "subscription.charged"
        handle_subscription_charged(event)
      when "payment.authorized"
        handle_payment_authenticated(event)
      when "subscription.cancelled"
        handle_subscription_cancelled(event)
      when "payment.captured"
        handle_payment_captured(event)
      when "payment.failed"
        handle_payment_failed(event)
      else
        Rails.logger.info "Unhandled event type: #{event['event']}"
      end
  
      render json: { status: "success" }
    end
  
    private
  
    def verify_signature(payload, signature, secret)
      digest = OpenSSL::Digest.new('sha256')
      expected_signature = OpenSSL::HMAC.hexdigest(digest, secret, payload)
      Rack::Utils.secure_compare(expected_signature, signature)
    end
  
    def handle_subscription_activated(event)
      customer_id = event["payload"]["payment"]["entity"]["customer_id"]
      account = AccountBlock::Account.find_by(razorpay_customer_id: customer_id)

      @plan_id =  event["payload"]["subscription"]["entity"]["plan_id"]
      subscription = BxBlockCustomUserSubs::Subscription.find_by(razorpay_plan_id: @plan_id)

      if account.present?
        current_active_subscription = account.sub_scription_orders.where(active_plan: true)
        if current_active_subscription.exists?
          current_active_subscription.update_all(active_plan: false)
        end 

        user_current_plan = account.sub_scription_orders.find_by(subscription_id: subscription.id)
        
        user_current_plan.update(active_plan: true, status: "success") if user_current_plan.present?
        if account.setting.in_app_notification?
          BxBlockNotifications::Notification.create(
            account_id: account.id,
            read_at: DateTime.now,
            contents: "Thank you for subscribing! Your #{subscription.name} subscription is now activate."
          )
        end
      else
        Rails.logger.error "Account not found for Razorpay customer_id: #{customer_id}"
      end

      BxBlockSubscriptionBilling::SubscriptionEmailMailer.purchase_confirmation(account, subscription).deliver_now!
    end

    def handle_payment_authenticated(event)
     
    end
  
    def handle_subscription_charged(event)
    
    end
  
    def handle_subscription_cancelled(event)
   
    end
  
    def handle_payment_captured(event)
      @customer_id = event["payload"]["payment"]["entity"]["customer_id"]
    end
  
    def handle_payment_failed(event)
     
    end
  end
end
  