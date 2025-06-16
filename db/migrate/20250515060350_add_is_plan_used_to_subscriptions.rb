class AddIsPlanUsedToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :bx_block_custom_user_subs_subscriptions, :is_plan_used, :boolean, default: false
  end
end
