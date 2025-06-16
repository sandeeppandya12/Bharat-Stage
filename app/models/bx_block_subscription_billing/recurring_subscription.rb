module BxBlockSubscriptionBilling
  class RecurringSubscription < ApplicationRecord
    self.table_name = :recurring_subscriptions
    OPTIONS = %i[annually monthly quarterly]
    enum billing_frequency: OPTIONS
    validates :name, presence: true, uniqueness: {case_sensitive: false}
    validates :fee, numericality: {greater_than_or_equal_to: 0}, presence: true
    validates :billing_date, presence: true
    validates :billing_frequency, 
                presence: {message: "Billing Frequency cant be blank, Please select from the list #{OPTIONS}"}
  end
end
