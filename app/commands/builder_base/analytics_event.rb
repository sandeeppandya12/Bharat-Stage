module BuilderBase
  class AnalyticsEvent
    EVENT_NAME = "bx_block_analytics.publish_event"
    def self.publish(event_name:, identifier:, properties: {})
      ActiveSupport::Notifications.instrument(
        EVENT_NAME,
        {
          event_name: event_name,
          identifier: identifier,
          properties: properties
        }
      )
    end
  end
end
