module BxBlockForgotPassword
  class PasswordsController < ApplicationController
    def reset_password
      @account = AccountBlock::Account.find_by(email: params[:email])
      
      if @account
        @account.generate_password_reset_token!
        AccountBlock::AccountMailer.password_reset_email(@account).deliver_now
        render json: { message: "Password reset email sent!" }
      else
        render json: { error: "Account Not Found!" }, status: :not_found
      end
    end

    def change_password
      @account = AccountBlock::Account.find_by(reset_password_token: params[:reset_token])
      
      if @account.nil?
        render json: { alert: "Invalid or expired token." }, status: :unprocessable_entity
        return
      end
    
      if params[:password] != params[:password_confirmation]
        render json: { alert: "Passwords do not match." }, status: :unprocessable_entity
        return
      end
    
      begin
        @account.reset_password!(params[:password])  # This will also invalidate the token after use
        if @account.setting.in_app_notification?
          BxBlockNotifications::Notification.create(
            account_id: @account.id,   
            read_at: DateTime.now,  
            headings: "reset password",
            contents: "Your password has been changed successfully.",
          )
        end
        render json: { message: "Password has been successfully reset." }, status: :ok
      rescue => e
        render json: { alert: e.message }, status: :unprocessable_entity
      end
    end
    
  end
end
