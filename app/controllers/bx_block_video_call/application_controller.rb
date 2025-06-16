module BxBlockVideoCall
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    include CheckCurrentUser

    before_action :validate_json_web_token
  end
end
