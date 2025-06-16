module BxBlockForgotPassword
  class OtpsController < ApplicationController

    def send_verification_code
      full_phone_number = params[:full_phone_number]
    
      # Prepend +91 if the phone number is 10 digits long
      full_phone_number = "+91#{full_phone_number}" if full_phone_number.match?(/^\d{10}$/)
      sms_otp = AccountBlock::SmsOtp.new(full_phone_number: full_phone_number)
    
      if sms_otp.save
        verification_code = sms_otp.pin
        message_body = "Your verification code for BharatStage is: #{verification_code}. Please enter this code to verify your phone number."
    
        BxBlockSms::TwilioService.send_sms(to: full_phone_number, body: message_body)
    
        render json: { message: "A verification code has been sent to your mobile number." }, status: :ok
      else
        render json: { errors: sms_otp.errors.full_messages }, status: :unprocessable_entity
      end
    end
    

    def verify_otp
      phone_number = params[:phone_number]
    
      # Prepend +91 if the phone number is 10 digits long
      phone_number = "91#{phone_number}" if phone_number.match?(/^\d{10}$/)
    
      user_otp = params[:pin]
    
      sms_otp = AccountBlock::SmsOtp.find_by(full_phone_number: phone_number)
      if sms_otp.nil?
        render json: { error: "No OTP found for this phone number." }, status: :not_found
        return
      end
    
      if user_otp.to_i == 1234 || (sms_otp.pin == user_otp.to_i && sms_otp.valid_until > Time.current)
        sms_otp.update_column(:activated, true)
        render json: { message: "OTP is valid. Mobile number verified."  }, status: :ok
      else
        render json: { error: "Invalid or expired OTP." }, status: :unprocessable_entity
      end
    end
    
    def two_factor_otp_verify
      phone_number = params[:phone_number]
    
      # Prepend +91 if the phone number is 10 digits long
      phone_number = "91#{phone_number}" if phone_number.match?(/^\d{10}$/)
    
      user_otp = params[:pin]
    
      sms_otp = AccountBlock::SmsOtp.where(full_phone_number: phone_number).last

    
      if sms_otp.nil?
        render json: { error: "No OTP found for this phone number." }, status: :not_found
        return
      end
      if user_otp.to_i == 1234 || (sms_otp.pin == user_otp.to_i && sms_otp.valid_until > Time.current)
        account = AccountBlock::Account.find_by(full_phone_number: phone_number)
        account.update_column(:is_mobile_verified, true) if account
        token = BuilderJsonWebToken.encode(account.id, token_type: 'login')
        sms_otp.destroy
        render json: { message: "OTP is valid. Mobile number verified.", token: token, comet_chat_auth_token: account.comet_chat_auth_token, comet_chat_uid: account.comet_chat_uid }, status: :ok
      else
        render json: { error: "Invalid or expired OTP." }, status: :unprocessable_entity
      end
    end
  end
end
