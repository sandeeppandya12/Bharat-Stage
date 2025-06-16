module BxBlockProfile
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    before_action :validate_json_web_token
    # serialization_scope :view_context

     def current_user
      token = request.headers[:token] || params[:token]
      return nil if token.blank?
      @token = BuilderJsonWebToken::JsonWebToken.decode(token)
      @current_user ||= AccountBlock::Account.find(@token.id)
    rescue ActiveRecord::RecordNotFound
      render json: {
        errors: [{message: "Authentication token invalid"}]
      }, status: :unprocessable_entity
    end

    private

    def format_activerecord_errors(errors)
      result = []
      errors.each do |attribute, error|
        result << { attribute => error }
      end
      result
    end
  end
end
