# app/services/bx_block_sms/twilio_service.rb
require 'twilio-ruby'
module BxBlockSms
    class TwilioService
      def self.send_sms(to:, body:)
        client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
        message = client.messages.create(
          from: ENV['TWILIO_PHONE_NUMBER'],
          to: to,
          body: body
        )
  
        message.sid
      rescue Twilio::REST::RestError => e
        Rails.logger.error "Twilio error: #{e.message}"
        nil
      end
    end
  end
  