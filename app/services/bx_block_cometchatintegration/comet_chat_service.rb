require 'httparty'
module BxBlockCometchatintegration
  class CometChatService
    include HTTParty
    # base_uri "https://#{ENV['COMETCHAT_APP_ID']}.api-#{ENV['COMETCHAT_REGION']}.cometchat.io/v3"
    base_uri "https://268092165dd74759.api-in.cometchat.io/v3"

    CONTENT_TYPE = 'application/json'.freeze

    def self.create_user(uid, name)
      response = post(
        "/users",
        headers: {
          "Content-Type" => CONTENT_TYPE,
          "Accept" => CONTENT_TYPE,
          "apikey" => ENV['COMETCHAT_API_KEY']
        },
        body: { uid: uid, name: name }.to_json
      )
      response.parsed_response 
    end

    def self.generate_auth_token(uid)
      response = post(
        "/users/#{uid}/auth_tokens",
        headers: {
          "Content-Type" => CONTENT_TYPE,
          "Accept" => CONTENT_TYPE,
          "apikey" => ENV['COMETCHAT_API_KEY']
        }
      )
      response.parsed_response
    end
  end
end
