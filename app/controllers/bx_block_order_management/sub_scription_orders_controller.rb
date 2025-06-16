module BxBlockOrderManagement
  class SubScriptionOrdersController < BxBlockOrderManagement::ApplicationController
  	include BuilderJsonWebToken::JsonWebTokenValidation
  	include JSONAPI::Deserialization

	  before_action :find_account
	  before_action :find_subscription, only: [:index]

	  def index
	  	valid_date = calculate_valid_date(@subscription.name)

	    if @subscription.name.downcase == "free"
	    	if has_used_free_plan?
      		render json: { error: "You have already subscribed to the free plan." }, status: :forbidden
      		return
    		end
	    	
        order = @account.sub_scription_orders.create!(subscription: @subscription,
			    order_date: Time.current,
			    valid_date: valid_date,
			    status: "success",
			    active_plan: true,
			    order_number: generate_order_number(@subscription.name)
			  )
        if @account.setting.in_app_notification?
				  BxBlockNotifications::Notification.create(
	          account_id: @account.id,
	          read_at: DateTime.now,
	          contents: "Thank you for subscribing! Your Free subscription is now activate."
	        )
	      end
        BxBlockSubscriptionBilling::SubscriptionEmailMailer.purchase_confirmation(@account, @subscription).deliver_now!

        render json: { 
        	message: "Congratulations! Your free plan has started from '#{format_date(Time.current)}' to '#{format_date(valid_date)}'." ,
        	order_details: BxBlockOrderManagement::SubScriptionOrderSerializer.new(order).serializable_hash
        }, status: :ok
        return
      end

      unless can_subscribe_to_monthly_plan?
					render json: { error: "your plan is active you con't buy a new plan" }, status: :forbidden
		      return
	    	end

      gst_amount = (@subscription.price * 0.18).round(2)

	    order = @account.sub_scription_orders.create!(
	      subscription: @subscription,
	      sub_total: @subscription.price,
	      gst: gst_amount,
	      status: "pending",
	      total: calculate_total_price(@subscription.price),
	      order_date: Time.current,
	      valid_date: valid_date,
	      order_number: generate_order_number(@subscription.name)
	    )

	    if order.persisted?
	      # order.update(status: "success")

	      render json: BxBlockOrderManagement::SubScriptionOrderSerializer.new(order).serializable_hash, status: :ok
	    else
	      render json: { error: "Order creation failed." }, status: :unprocessable_entity
	    end
	  end

	  def user_current_plan 
	  	@user_current_plan = @account.sub_scription_orders.find_by(active_plan: true)
	  	if @user_current_plan.present?
	  	  render json: BxBlockOrderManagement::SubScriptionOrderSerializer.new(@user_current_plan).serializable_hash, status: :ok
      else
      	render json: { error: "User current plan not found." }, status: :not_found
      end
	  end

	  def user_all_plans 
	  	@scription_orders = @account.sub_scription_orders.all
	  	if @scription_orders.present?
	  	  render json: BxBlockOrderManagement::SubScriptionOrderSerializer.new(@scription_orders).serializable_hash, status: :ok
      else
      	render json: { error: "Plan not found." }, status: :not_found
      end
	  end

	  private

	  def find_account
      @account = AccountBlock::Account.find_by(id: @token.id)
      render json: { error: 'Account not found' }, status: :not_found unless @account
    end

	  def find_subscription
	    @subscription = BxBlockCustomUserSubs::Subscription.find_by(id: params[:subscription_id])
	    render json: { error: 'Subscription not found' }, status: :not_found unless @subscription
	  end

	  def calculate_total_price(price)
	    (price * 1.18).round(2)
	  end

	  def calculate_valid_date(subscription_name)
      case subscription_name.downcase
      when "yearly"
        1.year.from_now
      when "monthly"
        1.month.from_now
      else
        1.year.from_now 
      end
    end

	  def generate_order_number(subscription_name)
		  type_code = { "free" => "F", "monthly" => "M", "yearly" => "Y" }[subscription_name.downcase] || "X"
		  date_part = Time.current.strftime("%d%m%Y")

		  last_order = BxBlockOrderManagement::SubScriptionOrder
		                .where("order_number LIKE ?", "##{type_code}#{date_part}%")
		                .order(order_number: :desc)
		                .first

		  last_number = last_order&.order_number&.match(/(\d{6})$/)&.captures&.first.to_i || 0
		  new_number = format("%06d", last_number + 1) 

		  "##{type_code}#{date_part}#{new_number}" 
		end

		def format_date(date)
		  date.in_time_zone("Asia/Kolkata").strftime("%d/%m/%Y (%I:%M %p)")
		end

		def has_used_free_plan?
  		@account.sub_scription_orders.exists?(subscription_id: @subscription.id)
		end

		def can_subscribe_to_monthly_plan?
		  # If the user has no existing subscriptions, allow subscribing to any plan
		  return true if @account.sub_scription_orders.empty?

		  # Check if any active subscription is of a paid type (monthly or yearly)
		  @account.sub_scription_orders.where(active_plan: true).each do |order|
		    if order.subscription.name.downcase.in?(['yearly'])
		      return false
		    end
		  end
		  true
		end
	end
end
