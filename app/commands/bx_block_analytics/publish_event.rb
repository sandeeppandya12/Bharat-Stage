module BxBlockAnalytics
  class PublishEvent
    def self.call(event_name:, identifier:, properties: {})
      ActiveSupport::Notifications.instrument(
        BX_BLOCK_ANALYTICS_EVENT_NAME,
        {
          event_name: event_name,
          identifier: identifier,
          properties: properties
        }
      )
    end
  end
end
