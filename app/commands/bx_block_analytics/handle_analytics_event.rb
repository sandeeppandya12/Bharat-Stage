# frozen_string_literal: true

module BxBlockAnalytics
  class HandleAnalyticsEvent
    attr_internal :event
    def initialize(event)
      @_event = event
    end

    def call
      raise NotImplementedError
    end
  end
end
