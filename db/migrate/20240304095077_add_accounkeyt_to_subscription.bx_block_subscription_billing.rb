# This migration comes from bx_block_subscription_billing (originally 20221104070138)
class AddAccounkeytToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_reference :recurring_subscriptions, :account, foreign_key: true
  end
end
