# frozen_string_literal: true

require "uri"
require "net/http"

module BxBlockBuilderAnalytics
  class HandleAnalyticsEvent < BxBlockAnalytics::HandleAnalyticsEvent
    attr_internal :event, :endpoint

    def initialize(event, endpoint: BuilderAnalyticsConfig.analytics_endpoint)
      @_event = event
      @_endpoint = endpoint
    end

    def call
      uri = URI.parse(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = "application/json"

      body = {
        type: "analytics_event",
        data: { event: event.payload[:event_name],
                userId: event.payload[:identifier],
                properties: event.payload[:properties] }
      }
      request.body = body.to_json

      http.request(request)
    end
  end
end
