module BxBlockChat
  class ApplicationController < BuilderBase::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    include PublicActivity::StoreController

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def not_found
      render json: {"errors" => ["Record not found"]}, status: :not_found
    end

    def serialization_options
      {params: {host: request.protocol + request.host_with_port}}
    end

    def chat_message_serialization_options
      {params: {host: request.protocol + request.host_with_port, receiver_id: params[:receiver_id]}}
    end
  end
end
