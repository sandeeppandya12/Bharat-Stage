module BxBlockSubscriptionBilling
  class RecurringSubscriptionSerializer < BuilderBase::BaseSerializer
    attributes(:id, :name, :fee, :billing_date, :billing_frequency)
  end
end
