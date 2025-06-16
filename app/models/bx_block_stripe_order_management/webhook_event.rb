module BxBlockStripeOrderManagement
  class WebhookEvent
    include ActiveModel::Model
    include Processable

    attr_accessor :event_id, :event_type, :object_id, :payable_reference, :payload
  end
end
