module BxBlockRazorpay
  class RazorpayIntegration
    require 'razorpay'

    def initialize
      Razorpay.setup(
        ENV['RAZORPAY_KEY_ID'],
        ENV['RAZORPAY_SECRET_KEY']
      )
    end

    def fetch_subscription
      Razorpay::Subscription.all
    end

    def create_subscription(user, plan_id, auto_renew)
      return nil unless plan_id
    
      customer_id = user.razorpay_customer_id
      return nil if customer_id.nil?
    
      Rails.logger.info "Creating subscription for Customer: #{customer_id}, Plan: #{plan_id}"

      total_count = auto_renew ? 12 : 1
      begin
        razorpay_subscription = Razorpay::Subscription.create({
          plan_id: plan_id,
          customer_id: customer_id, 
          customer_notify: 1,
          total_count: total_count
        })
        
        Rails.logger.info "Subscription Created Successfully: #{razorpay_subscription.inspect}"
        razorpay_subscription
      rescue Razorpay::Error => e
        Rails.logger.error "Razorpay Subscription Creation Failed: #{e.message} - #{e.json_body}"
        nil
      end
    end


    def create_plan(name, price, period, description = nil)
      gst_price = (price * 1.18).to_i 
      plan = Razorpay::Plan.create({
        period: period,
        interval: 1,
        item: {
          name: name,
          amount: gst_price * 100,
          currency: 'INR',
          description: description
        }
      })
      plan.id
    rescue Razorpay::Error => e
      Rails.logger.error "Razorpay Plan Creation Failed: #{e.message}"
      nil
    end

   
    def create_customer(user)
      Razorpay::Customer.create({
        name:  "#{user.first_name} #{user.last_name}".strip,
        email: user.email,
        contact: user.full_phone_number
      })
    rescue Razorpay::Error => e
      Rails.logger.error "Razorpay Customer Creation Failed: #{e.message}"
      nil
    end

    def fetch_subscription_stats
      subscriptions = Razorpay::Subscription.all
      
      total_amount = 0
      active_subscriptions = 0
      monthly_count = 0
      yearly_count = 0
      subscriptions.items.each do |subscription|
        if subscription
          plan_id = subscription['plan_id']
          
          plan_details = fetch_plan_details(plan_id)

          total_amount += plan_details[:amount]

          active_subscriptions += 1
          plan_type = fetch_plan_details(plan_id)
          plan_interval = plan_type[:interval]
          if plan_interval == 'Monthly'
            monthly_count += 1
          elsif plan_interval == 'Yearly'
            yearly_count += 1
          end
        end
      end
      
      {
        total_amount: total_amount,
        active_subscriptions: active_subscriptions,
        monthly_count: monthly_count,
        yearly_count: yearly_count
      }
    rescue Razorpay::Error => e
      Rails.logger.error "Error fetching subscription stats: #{e.message}"
      nil
    end
    
    def fetch_plan_details(plan_id)
      plan = Razorpay::Plan.fetch(plan_id)
      amount = plan.attributes['item']['amount'] / 100.0
      interval = plan.attributes['item']['name']
      
      { amount: amount, interval: interval }
    end

  end
end
