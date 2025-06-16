module BxBlockSubscriptionBilling
  class SubscriptionEmailMailer < ApplicationMailer
    def purchase_confirmation(account, subscription)
      @account = account
      @subscription = subscription
      mail(to: @account.email, subject: "Subscription Purchase Confirmation")
    end

    def subscription_expired(account)
      @account = account

      mail(
        to: @account.email,
        from: "builder.bx_dev@engineer.ai",
        subject: "Subscription Expired"
      ) do |format|
        format.html { render "subscription_expired" }
      end
    end

    def renewal_reminder(account, order)
      @account = account
      @renewal_date = order.valid_date.strftime("%B %d, %Y")
      mail(to: @account.email, subject: 'Subscription Renewal Reminder')
    end

    def renewal_confirmation(account)
      @account = account
      mail(to: @account.email, subject: 'Subscription Renewal Confirmation')
    end

  end
end
