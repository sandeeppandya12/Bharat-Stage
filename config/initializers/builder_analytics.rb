# frozen_string_literal: true

require BxBlockBuilderAnalytics::Engine.root.join("lib", "bx_block_builder_analytics", "builder_analytics_config.rb").to_s

BxBlockBuilderAnalytics::BuilderAnalyticsConfig.analytics_endpoint = ENV["BCS_REQUEST_URL"]
