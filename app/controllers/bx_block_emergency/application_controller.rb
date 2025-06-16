module BxBlockEmergency
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token
    before_action :current_user

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def current_user
      return unless @token

      @current_user ||= AccountBlock::Account.find(@token.id)
    end
  end
end
