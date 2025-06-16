module BxBlockAnalytics
  class MissingEventName < StandardError
    def initialize(msg = "Required analytics_event parameters not provided")
      super
    end
  end
end
