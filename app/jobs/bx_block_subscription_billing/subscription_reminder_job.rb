module BxBlockSubscriptionBilling
	class SubscriptionReminderJob < ApplicationJob
	  queue_as :default

	  def perform
	    target_date = Date.today + 2.days

      orders = BxBlockOrderManagement::SubScriptionOrder.where(
        valid_date: target_date,
        auto_renewal: true,
        active_plan: true
      )

      orders.each do |order|
        account = AccountBlock::Account.find_by(id: order.account_id)
        next unless account.present?

        BxBlockSubscriptionBilling::SubscriptionEmailMailer.renewal_reminder(account, order).deliver_now!
      end
	  end

	  def subscription_expire
      today = Date.today

      expired_orders = BxBlockOrderManagement::SubScriptionOrder.where(
        "valid_date <= ?", today
      ).where(
        active_plan: true,
        auto_renewal: false
      )

      expired_orders.each do |order|
        account = AccountBlock::Account.find_by(id: order.account_id)
        next unless account

        BxBlockSubscriptionBilling::SubscriptionEmailMailer.subscription_expired(account).deliver_now!

        order.update(active_plan: false, status: "expired")
      end
    end

    def renewal_confirm
      today = Date.today

      orders_to_renew = BxBlockOrderManagement::SubScriptionOrder.where(
        valid_date: today,
        auto_renewal: true,
        active_plan: true
      )

      orders_to_renew.each do |old_order|
        account = AccountBlock::Account.find_by(id: old_order.account_id)
        next unless account

        old_order.update(active_plan: false, status: 'renewed')

        new_valid_date = old_order.valid_date + 1.month
        BxBlockOrderManagement::SubScriptionOrder.create!(
          account_id: old_order.account_id,
          subscription_id: old_order.subscription_id,
          gst: old_order.gst,
          sub_total: old_order.sub_total,
          total: old_order.total,
          order_date: today,
          valid_date: new_valid_date,
          status: "active",
          order_number: SecureRandom.hex(6),
          auto_renewal: true,
          active_plan: true
        )

        BxBlockSubscriptionBilling::SubscriptionEmailMailer.renewal_confirmation(account).deliver_now!
      end
    end
	end
end