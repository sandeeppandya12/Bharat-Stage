module BxBlockStripeIntegration
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token

    private

    def not_found
      render json: {"errors" => ["Record not found"]}, status: :not_found
    end

    def current_user
      @current_user ||= AccountBlock::Account.find(@token.id)
    end

    def current_stripe_customer
      @current_stripe_customer ||= Customer.find_or_create_by_account(current_user)
    end

    def validate_parameters(params_to_check, parameter_names)
      parameter_names.each do |parameter_name|
        unless params_to_check[parameter_name].present?
          render json: {
            errors: [params: "#{parameter_name} is not provided"]
          }, status: :unprocessable_entity and return false
        end
      end
    end
  end
end
