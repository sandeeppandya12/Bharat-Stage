module BxBlockCustomUserSubs
  class SubscriptionsController < ApplicationController

    def index
      custom_order = ["Free", "Monthly", "Yearly"]
      token = request.headers['token']
      if token.present?
        decoded = BuilderJsonWebToken.decode(token)
        user = AccountBlock::Account.find_by(id: decoded.id)
        if user&.sub_scription_orders.present?
          user.subscriptions.any? { |s| custom_order.include?(s.name) }
          Subscription.where(name: "Free").update(is_plan_used: true)
        else
          Subscription.where(name: "Free").update(is_plan_used: false)
        end
      end

      subscriptions = Subscription.all

      sorted_subscriptions = subscriptions.sort_by do |subscription|
        custom_order.index(subscription.name)
      end

      render json: SubscriptionSerializer.new(sorted_subscriptions).serializable_hash, status: :ok
    end
  end
end
