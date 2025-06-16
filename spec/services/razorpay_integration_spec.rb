require 'rails_helper'
require 'razorpay'

RSpec.describe BxBlockRazorpay::RazorpayIntegration, type: :service do
  PASSWORD = "Password@123".freeze
  FULL_PHONE_NUMBER = "9999929999".freeze

  let!(:user) do
    FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com",
                                password: PASSWORD, password_confirmation: PASSWORD,
                                full_phone_number: FULL_PHONE_NUMBER,
                                terms_accepted: true, activated: true)
  end

  let!(:token) { BuilderJsonWebToken.encode(user.id, 2.days.from_now, token_type: 'login') }
  let(:plan) { BxBlockCustomUserSubs::Subscription.create(name: "Yearly", price: 500, description: 'hello') }
  let(:plan_id) { plan.id }
  let(:service) { described_class.new }

  before do
    allow(Razorpay).to receive(:setup).with(ENV['RAZORPAY_KEY_ID'], ENV['RAZORPAY_SECRET_KEY'])
  end

  describe '#create_subscription' do
    context 'when subscription is successfully created' do
      let(:subscription_response) { double('Razorpay::Subscription', id: 'sub_12345') }

      before do
        allow(Razorpay::Subscription).to receive(:create).and_return(subscription_response)
      end

      it 'returns the subscription object' do
        result = service.create_subscription(user, plan_id, true)
      end
    end

    context 'when Razorpay API raises an error' do
      before do
        allow(Razorpay::Subscription).to receive(:create).and_raise(Razorpay::Error.new('API Error'))
      end

    end
  end

  describe '#create_plan' do
    let(:plan_response) { double('Razorpay::Plan', id: 'plan_12345') }

    context 'when plan is successfully created' do
      before do
        allow(Razorpay::Plan).to receive(:create).and_return(plan_response)
      end

      it 'returns the plan ID' do
        expect(service.create_plan('Yearly Plan', 500, 'monthly')).to eq('plan_12345')
      end
    end

    context 'when Razorpay API raises an error' do
      before do
        allow(Razorpay::Plan).to receive(:create).and_raise(Razorpay::Error.new('API Error'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Razorpay Plan Creation Failed/)
        expect(service.create_plan('Yearly Plan', 500, 'monthly')).to be_nil
      end
    end
  end

  describe '#create_customer' do
    let(:customer_response) { double('Razorpay::Customer', id: 'cust_67890') }

    context 'when customer is successfully created' do
      before do
        allow(Razorpay::Customer).to receive(:create).and_return(customer_response)
      end

      it 'returns the customer object' do
        expect(service.create_customer(user).id).to eq('cust_67890')
      end
    end

    context 'when Razorpay API raises an error' do
      before do
        allow(Razorpay::Customer).to receive(:create).and_raise(Razorpay::Error.new('API Error'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Razorpay Customer Creation Failed/)
        expect(service.create_customer(user)).to be_nil
      end
    end
  end
end
