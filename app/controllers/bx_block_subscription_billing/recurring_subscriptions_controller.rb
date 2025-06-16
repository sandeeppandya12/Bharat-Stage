module BxBlockSubscriptionBilling
  class RecurringSubscriptionsController < ApplicationController
    before_action :set_recurring_subscription, only: [:show, :destroy, :update]

    def create
      if recurring_subscription_params[:fee].present? && recurring_subscription_params[:fee].first.include?("-")
        render json: {error:
          [message: "must be greater than 0 or equal to 0"]},
        status: 400
      else
        recurring_subscription =
        RecurringSubscription.new(recurring_subscription_params.merge({account_id: current_user.id}))
        if recurring_subscription.save
          render json: recurring_subscription, status: :created
        else
          render json: recurring_subscription.errors, status: :unprocessable_entity
        end
      end
    rescue ArgumentError
      data = RecurringSubscription::OPTIONS
      render json: {error:
          [message: "Billing Frequency not in list #{data}"]},
        status: 400
    end

    def update
      if @recurring_subscription.account_id == current_user.id
        begin
        if @recurring_subscription.update(recurring_subscription_params)
          render json: @recurring_subscription, message: " Updated successfully", status: :ok
        else
          render json: @recurring_subscription.errors, status: :bad_request
        end
        rescue ArgumentError
          data = RecurringSubscription::OPTIONS
          render json: {error: [message: "Billing Frequency not in list #{data}"]}, status: 400
        end 
      else
        render json: {error: [message: "You can not update this recurring subscription"]},
        status: :unprocessable_entity
      end
    end

    def index
      recurring_subscriptions = RecurringSubscription.all
      render json: RecurringSubscriptionSerializer.new(recurring_subscriptions), status: 200
    end

    def destroy
      if @recurring_subscription.account_id == current_user.id
        if @recurring_subscription.destroy
          render json: {message: "Subscription Billing removed"}, status: :ok
        end
      else
        render json: {message: "You Can't Destroy This Subscription Billing."}, status: :unprocessable_entity
      end
    end

    private

    def set_recurring_subscription
      @recurring_subscription = RecurringSubscription.find(params[:id])
      return render json: {message: "Record not found"}, status: 404 unless @recurring_subscription
    end

    def recurring_subscription_params
      params.require(:recurring_subscription).permit(:id, :name, :fee, :billing_date, :billing_frequency, :account_id)
    end
  end
end
