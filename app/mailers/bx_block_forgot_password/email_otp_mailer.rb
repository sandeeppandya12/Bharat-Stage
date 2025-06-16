module BxBlockForgotPassword
  class EmailOtpMailer < ApplicationMailer
    default from: "management@bharatstage.com"
    def otp_email(otp, account, host)
      @otp = otp.pin
      @email = otp.email
      @first_name = account.first_name
      @host = Rails.env.development? ? 'http://localhost:3000' : host
      mail(
          to: @email,
          subject: 'Confirm Your Email Address Change') do |format|
        format.html { render 'otp_email' }
      end
    end
  end
end
