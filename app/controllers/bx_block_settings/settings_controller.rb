module BxBlockSettings
  class SettingsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    include CometchatUpdatable
    before_action :validate_json_web_token
    before_action :set_account, only: [:toggle_two_factor, :update_notification, :update_account_profile, :update_account_email, :index, :update_password, :verify_email_otp, :verify_and_update_phone_number]

    def index
      settings = @account.setting
      render json: BxBlockSettings::SettingSerializer.new(settings).serializable_hash, status: :ok
    end

    def toggle_two_factor
      @setting = @account.setting
      if @setting.update(two_factor_enabled: params[:two_factor_enabled])
        render json: { success: true, message: "Two-Factor Authentication successfully updated.", two_factor_enabled: @setting.two_factor_enabled }, status: :ok
      else
        render json: { success: false, message: @setting.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def update_notification
      @setting = @account.setting
      if @setting.update(notification_settings_params)
        render json: {
          success: true,
          message: "Notification settings updated successfully.",
          data: @setting.slice(:desktop_notification, :in_app_notification, :email_notification, :chat_notification)
        }, status: :ok
      else
        render json: { success: false, message: @setting.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update_account_profile
      if @account.update(account_params)
        update_cometchat_profile(@account)
        render json: { message: 'Account updated successfully', data: @account }, status: :ok
      else
        render json: { errors: @account.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update_account_email
      validator = AccountBlock::EmailValidation.new(params[:email])
        unless validator.valid?
        return render json: { errors: [{ account: 'Provided email address is invalid.' }] }, status: :unprocessable_entity
      end

      existing_account = AccountBlock::Account.find_by(email: params[:email])
      
      if existing_account.present?
        return render json: { error: 'Email address is already associated with another account.' }, status: :unprocessable_entity
      end

      otp = AccountBlock::EmailOtp.create!(email: params[:email], activated: true)
      BxBlockForgotPassword::EmailOtpMailer.otp_email(otp, @account, host: request.base_url).deliver_now
      render json: { message: 'OTP sent to the new email. Please verify to complete the update.', email: params[:email] }
    end

    def verify_email_otp
      otp_record = AccountBlock::EmailOtp.find_by(pin: params[:otp].to_i, activated: true)

      if otp_record.nil? || otp_record.valid_until < Time.current
        return render json: { error: 'Invalid or expired OTP.' }, status: :unprocessable_entity
      end

      @account.update(email: otp_record.email, is_email_verify: true)
      otp_record.destroy

      render json: { message: 'Email successfully updated' }
    end

    def update_password
      if params[:new_password].blank? || params[:password_confirmation].blank?
        render json: { error: 'New password and password confirmation are required' }, status: :unprocessable_entity
        return
      end

      if !@account.authenticate(params[:current_password])
        render json: { error: 'incorrect password' }, status: :unauthorized
        return
      end

      if params[:new_password] == params[:password_confirmation]
        if params[:new_password] != params[:current_password]
          if @account.update(password: params[:new_password])
            send_password_change_notification
            render json: { message: 'Password changed successfully' }
          else
            render json: { errors: @account.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: {
            errors: [{ 
              message: "Your new password must be different from your current password",
            }],
          }, status: :unprocessable_entity
        end
      else
        render json: {
          errors: [{
            message: "Password should match with Password Confirmation",
          }],
        }, status: :unprocessable_entity
      end
    end

    def send_phone_update_code
      full_phone_number = params[:full_phone_number]
    
      # Prepend 91 if the phone number is 10 digits long
      full_phone_number = "91#{full_phone_number}" if full_phone_number.match?(/^\d{10}$/)

      if AccountBlock::Account.where(full_phone_number: full_phone_number).exists?
        return render json: { error: "This phone number is already associated with another account." }, status: :unprocessable_entity
      end

      sms_otp = AccountBlock::SmsOtp.new(full_phone_number: full_phone_number, activated: true)
    
      if sms_otp.save
        verification_code = sms_otp.pin
        message_body = "Your verification code for BharatStage is: #{verification_code}. Please enter this code to verify your phone number."
    
        BxBlockSms::TwilioService.send_sms(to: full_phone_number, body: message_body)
    
        render json: { message: "A verification code has been sent to your mobile number.", code: verification_code }, status: :ok
      else
        render json: { errors: sms_otp.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def verify_and_update_phone_number
      phone_record = AccountBlock::SmsOtp.find_by(pin: params[:otp].to_i, activated: true)

      if phone_record.nil? || phone_record.valid_until < Time.current
        return render json: { error: 'Invalid or expired OTP.' }, status: :unprocessable_entity
      end
        
      @account.update!(full_phone_number: phone_record.full_phone_number)
      phone_record.destroy!

      render json: { message: 'Phone number successfully updated.' }, status: :ok
    end

    private

    def notification_settings_params
      params.permit(:desktop_notification, :in_app_notification, :email_notification, :chat_notification)
    end

    def account_params
      params.permit(:first_name, :last_name, :roles)
    end

    def set_account
      @account = AccountBlock::Account.find_by(id: @token.id)
      
      if @account.nil?
        render json: { success: false, message: "Account not found." }, status: :not_found
        return
      end
    end

    def send_password_change_notification
      return unless @account.setting&.in_app_notification?

      BxBlockNotifications::Notification.create(
        account_id: @account.id,
        read_at: DateTime.now,
        headings: "Reset Password",
        contents: "Your password has been changed successfully."
      )
    end
  end
end
