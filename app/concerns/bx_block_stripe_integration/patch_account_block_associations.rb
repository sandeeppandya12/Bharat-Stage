module BxBlockStripeIntegration
  module PatchAccountBlockAssociations
    extend ActiveSupport::Concern

    included do
      has_one :stripe_customer, class_name: "BxBlockStripeIntegration::Customer", dependent: :destroy
    end
  end
end
