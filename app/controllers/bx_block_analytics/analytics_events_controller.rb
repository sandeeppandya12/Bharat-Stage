# frozen_string_literal: true

module BxBlockAnalytics
  class AnalyticsEventsController < BxBlockAnalytics::ApplicationController
    def create
      raise ::BxBlockAnalytics::MissingEventName if event_params["name"].blank?

      BxBlockAnalytics::PublishEvent.call(
        event_name: event_params["name"],
        identifier: current_user.id,
        properties: event_params["properties"].to_h
      )
      render status: :no_content
    rescue ::BxBlockAnalytics::MissingEventName => e
      render json: {errors: [analytics_event: e.message]}, status: :unprocessable_entity
    rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
      render json: {errors: [analytics_event: "Unauthorised"]}, status: :unauthorized
    end

    private

    def event_params
      params.require(:analytics_event).permit(
        :name,
        properties: {}
      )
    end
  end
end
