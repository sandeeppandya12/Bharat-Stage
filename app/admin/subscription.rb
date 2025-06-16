module Subscription
  class Load
    @@loaded_from_gem = false
    def self.is_loaded_from_gem
      @@loaded_from_gem
    end

    def self.loaded
    end

    # Check if this file is loaded from gem directory or not
    @@loaded_from_gem = Load.method('loaded').source_location.first.include?('bx_block_')
  end
end

unless Subscription::Load.is_loaded_from_gem
  ActiveAdmin.register BxBlockCustomUserSubs::Subscription, as: 'Subscription' do
    menu label: "Subscription"
    menu priority: 15

    actions :all, except: [:destroy, :new]
    permit_params :price

    form do |f|
      f.semantic_errors
      f.inputs do
        f.input :price
      end
      f.actions
    end

    index title: 'Subscriptions' do
      id_column
      column :name
      column :description
      column("Price") { |subscription| subscription.price.to_i }
      column :valid_up_to
      actions
    end

    show do
      attributes_table do
        row :id
        row :name
        row :description
        row("Price") { |subscription| subscription.price.to_i }
        row :valid_up_to
        row :image do |subscription|
          if subscription.image&.attached?
            image_tag url_for(subscription.image), width: 100
          else
            "No Image"
          end
        end
      end
    end

    controller do
      def update
        subscription = BxBlockCustomUserSubs::Subscription.find(params[:id])

        interval = case subscription.name
           when "Monthly"
             "monthly"
           when "Yearly"
             "yearly"
           else
             raise "Unsupported subscription type"
           end

        if subscription.update(permitted_params[:subscription])
          razorpay = BxBlockRazorpay::RazorpayIntegration.new
          plan_id = razorpay.create_plan(subscription.name, subscription.price, interval, subscription.description)
          if plan_id.present?
            subscription.update(razorpay_plan_id: plan_id)
            Rails.logger.info "Razorpay Plan Created Successfully: #{plan_id}"
          else
            Rails.logger.error "Failed to create Razorpay plan for subscription: #{subscription.name}"
          end
          redirect_to admin_subscription_path(subscription), notice: "Price updated and Razorpay plan created!"
        else
          render :edit
        end
      end
    end
  end
end
