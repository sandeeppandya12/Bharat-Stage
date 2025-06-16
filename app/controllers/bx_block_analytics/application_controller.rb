# frozen_string_literal: true

module BxBlockAnalytics
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token

    private

    def current_user
      @current_user ||= AccountBlock::Account.find(@token.id)
    end
  end
end
