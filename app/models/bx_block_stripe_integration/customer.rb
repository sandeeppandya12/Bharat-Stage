module BxBlockStripeIntegration
  class Customer < ApplicationRecord
# Protected Area Start
    belongs_to :account, class_name: "AccountBlock::Account"

# Protected Area End
    class << self
      def find_or_create_by_account(account)
        unless account.stripe_customer.present?
          stripe_customer = Stripe::Customer.create({email: account.email})
          account.create_stripe_customer(stripe_id: stripe_customer.id)
        end

        account.stripe_customer
      end
    end
  end
end
