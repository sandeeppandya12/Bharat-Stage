module BxBlockStripeIntegration
  class WebhookEvent < ApplicationRecord
    class << self
      def from_stripe_event(event)
        metadata = event.data.object.metadata
        payable_reference = metadata && metadata["payable_reference"]

        create!(
          event_id: event.id,
          event_type: event.type,
          object_id: event.data.object.id,
          payable_reference: payable_reference,
          payload: event.to_json
        )
      end
    end

    after_create :notify

    def notify
      ActiveSupport::Notifications.instrument("bx_block_stripe_integration.event_created", to_payload)
    end

    def to_payload
      as_json(only: %i[event_id event_type object_id payable_reference])
        .merge("payload" => JSON.parse(payload))
    end
  end
end
