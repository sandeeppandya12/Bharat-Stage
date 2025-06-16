require 'rails_helper'

RSpec.describe BxBlockSubscriptionBilling::SubscriptionReminderJob, type: :job do
  let(:today) { Date.today }

  PASSWORD = "Password@123".freeze
  let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
  let!(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }
  let(:subscription) { BxBlockCustomUserSubs::Subscription.create(name: "Free", price:50) }

  before do
    allow(BxBlockSubscriptionBilling::SubscriptionEmailMailer)
      .to receive_message_chain(:renewal_reminder, :deliver_now!)
    allow(BxBlockSubscriptionBilling::SubscriptionEmailMailer)
      .to receive_message_chain(:subscription_expired, :deliver_now!)
    allow(BxBlockSubscriptionBilling::SubscriptionEmailMailer)
      .to receive_message_chain(:renewal_confirmation, :deliver_now!)
  end

  describe '#perform (renewal reminder)' do
	  it 'sends reminder email to accounts with subscriptions expiring in 2 days' do
	    BxBlockOrderManagement::SubScriptionOrder.destroy_all

	    create(:sub_scription_order,
	      account: account,
	      subscription: subscription,
	      valid_date: Date.today + 2.days,
	      active_plan: true
	    )

	    described_class.new.perform

	    expect(BxBlockSubscriptionBilling::SubscriptionEmailMailer)
	      .to have_received(:renewal_reminder).once
	  end

  end

  describe '#subscription_expire' do
    it 'marks expired subscriptions and sends expiration emails' do
      create(:sub_scription_order,
        account: account,
        subscription: subscription,
        valid_date: today - 1.day,
        auto_renewal: false,
        active_plan: true
      )

      described_class.new.subscription_expire

      expect(BxBlockSubscriptionBilling::SubscriptionEmailMailer)
        .to have_received(:subscription_expired).once
    end
  end

  describe '#renewal_confirm' do
    it 'renews active subscriptions and sends confirmation emails' do
      old_order = create(:sub_scription_order,
        account: account,
        valid_date: today,
        auto_renewal: true,
        active_plan: true
      )

      expect {
        described_class.new.renewal_confirm
      }.to change { BxBlockOrderManagement::SubScriptionOrder.count }.by(1)

      expect(BxBlockSubscriptionBilling::SubscriptionEmailMailer)
        .to have_received(:renewal_confirmation).once

      old_order.reload
      expect(old_order.active_plan).to eq(false)
      expect(old_order.status).to eq('renewed')
    end
  end
end
