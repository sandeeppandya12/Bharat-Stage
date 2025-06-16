# This migration comes from bx_block_stripe_integration (originally 20231103164500)
class CreateBxBlockStripeIntegrationCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_stripe_integration_customers do |t|
      t.string :stripe_id
      t.belongs_to :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
