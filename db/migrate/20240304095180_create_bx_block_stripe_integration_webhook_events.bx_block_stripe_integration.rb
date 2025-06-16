# This migration comes from bx_block_stripe_integration (originally 20231106131959)
class CreateBxBlockStripeIntegrationWebhookEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_stripe_integration_webhook_events do |t|
      t.string :event_id
      t.string :event_type
      t.string :object_id
      t.string :payable_reference
      t.text :payload

      t.timestamps
    end
    add_index :bx_block_stripe_integration_webhook_events, :event_id
    add_index :bx_block_stripe_integration_webhook_events, :event_type
    add_index :bx_block_stripe_integration_webhook_events, :payable_reference, name: "index_bx_stripe_events_on_payable_ref"
    add_index :bx_block_stripe_integration_webhook_events, :object_id
  end
end
