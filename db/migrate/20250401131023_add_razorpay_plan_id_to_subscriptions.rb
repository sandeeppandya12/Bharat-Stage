class AddRazorpayPlanIdToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :bx_block_custom_user_subs_subscriptions, :razorpay_plan_id, :string
  end
end
