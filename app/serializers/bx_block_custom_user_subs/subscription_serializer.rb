module BxBlockCustomUserSubs
  class SubscriptionSerializer < BuilderBase::BaseSerializer
    attributes :name, :is_plan_used

     attribute :price do |object|
      object.price.to_f  # Convert BigDecimal to Float
    end

    
    # attribute :price do |object|
    #   object.price % 1 == 0 ? object.price.to_i : object.price.to_f
    # end

    # attribute :expired do |object|
    #   object.valid_up_to < Date.today
    # end

    # attribute :image_link do |object|
    #   object.image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(
    #     object.image,only_path: true
    #   ) : nil
    # end

    # attribute :subscribed do |object, params|
    #   BxBlockCustomUserSubs::Subscription.joins(:user_subscriptions).where(
    #     'user_subscriptions.account_id = ?', params[:user].id
    #   ).any?
    # end

  end
end
