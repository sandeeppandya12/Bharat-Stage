module BxBlockLogin
  class LoginsController < ApplicationController
    def create
      email = params[:email]
      account = AccountBlock::Account.where(email: email).first
    
      if account.nil?
        render json: {
          errors: [{
            failed_login: 'Email not found. Please check your email',
          }],
        }, status: :unprocessable_entity
        return
      end
    
      if !account.activated
        render json: {
          errors: [{
            account_not_activated: 'Your account is not activated. Please verify your email or contact support.',
          }],
        }, status: :unauthorized
        return
      end
    
      if account.blocked
        render json: {
          errors: [{
            account_blocked: 'Your account has been blocked. Please contact support for further assistance.',
          }],
        }, status: :unauthorized
        return
      end
      if account.setting.two_factor_enabled? && account.authenticate(params[:password])
        sms_otp = AccountBlock::SmsOtp.new(full_phone_number: "+91#{account.phone_number}")
      
        if sms_otp.save
          verification_code = sms_otp.pin
          message_body = "Your verification code for BharatStage is: #{verification_code}. Please enter this code to verify your phone number."
          BxBlockSms::TwilioService.send_sms(to: "+#{sms_otp.full_phone_number}", body: message_body)
          # return render json: { message: "A verification code has been sent to your mobile number." }, status: :ok
          return render json: { message: "A verification code has been sent to your mobile number.", two_factor_enabled: true , full_phone_number: sms_otp.full_phone_number.sub(/^91/, '')}, status: :ok

        else
          render json: { errors: sms_otp.errors.full_messages }, status: :unprocessable_entity
        end
      end
      if account.authenticate(params[:password])
        token = BuilderJsonWebToken.encode(account.id, 2.days.from_now, token_type: 'login')
        refresh_token = BuilderJsonWebToken.encode(account.id)
        render json: {
          message: 'Login successful',
          meta: {
            token: token,
            account_id: account.id,
            comet_chat_auth_token: account.comet_chat_auth_token,
            comet_chat_uid: account.comet_chat_uid
          }
        }, status: :ok
      else
        render json: {
          errors: [{
            wrong_password: 'Incorrect password. Please try again or use the Forgot Password link',
          }],
        }, status: :unauthorized
      end
    end
  end
end
