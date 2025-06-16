# This migration comes from bx_block_subscription_billing (originally 20220217042923)
class CreateBxBlockSubscriptionBillingRecurringSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :recurring_subscriptions do |t|
      t.string :name
      t.string :fee
      t.date :billing_date
      t.integer :billing_frequency
      t.timestamps
    end
  end
end
