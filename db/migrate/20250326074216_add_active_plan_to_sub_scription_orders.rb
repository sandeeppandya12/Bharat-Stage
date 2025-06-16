class AddActivePlanToSubScriptionOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :sub_scription_orders, :active_plan, :boolean, default: false
  end
end
