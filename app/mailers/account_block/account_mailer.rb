module AccountBlock
  class AccountMailer < ApplicationMailer
    default from: "management@bharatstage.com"

    def welcome_email(account)
      @account = account
      url = Rails.env.production? ? ENV['EMAIL_VERIFICATION_URL'] : 'http://localhost:3000/account_block/accounts/verify_account'
      @verification_link = "#{url}?token=#{@account.verification_token}"
      mail(to: @account.email, subject: "Verify Your Email")
    end

    def password_reset_email(account)
      @account = account
      url =  Rails.env.production? ? ENV['FORGOT_PASSWORD_URL'] : "http://localhost:3000/reset_password"
      @reset_url = "#{url}?token=#{@account.reset_password_token}"
      mail(to: @account.email, subject: 'Password Reset Instructions')
    end
  end
end