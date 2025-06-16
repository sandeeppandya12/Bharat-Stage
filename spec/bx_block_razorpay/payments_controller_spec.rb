require 'rails_helper'

RSpec.describe BxBlockRazorpay::PaymentsController, type: :request do
  PASSWORD = "Password@123".freeze
  FULL_PHONE_NUMBER = 9999929999.freeze

  let!(:account) do
    FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com",
                                password: PASSWORD, password_confirmation: PASSWORD,
                                full_phone_number: FULL_PHONE_NUMBER,
                                terms_accepted: true, activated: true)
  end

  let!(:token) { BuilderJsonWebToken.encode(account.id, 2.days.from_now, token_type: 'login') }

  let(:plan) { BxBlockCustomUserSubs::Subscription.create(name: "Yearly", price: 500, description: 'hello') }
  let(:razorpay_service) { instance_double(BxBlockRazorpay::RazorpayIntegration) }

  before do
    allow(BxBlockRazorpay::RazorpayIntegration).to receive(:new).and_return(razorpay_service)
  end

  describe "POST /bx_block_razorpay/payments/create_subscription" do
    context "when user is not logged in" do
      before do
        post "/bx_block_razorpay/payments/create_subscription",
             params: { plan_id: plan.id, auto_renew: true },
             headers: { 'token' => token },
             as: :json
      end
    end

    context "when subscription is successfully created" do
      let(:subscription_response) { OpenStruct.new(id: 'sub_12345') }

      before do
        allow_any_instance_of(BxBlockRazorpay::PaymentsController).to receive(:current_user).and_return(account)
        allow(razorpay_service).to receive(:create_subscription).and_return(subscription_response)

        post "/bx_block_razorpay/payments/create_subscription",
             params: { id: plan.id, auto_renew: true },
             headers: { 'token' => token },
             as: :json
      end

      it "returns success response with subscription details" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({
          "subscription_id" => "sub_12345",
          "full_phone_number" => account.full_phone_number,
          "email" => account.email,
          "first_name" => account.first_name,
          "last_name" => account.last_name,
          "status" => "created"
        })
      end
    end

    context "when subscription creation fails" do
      before do
        allow_any_instance_of(BxBlockRazorpay::PaymentsController).to receive(:current_user).and_return(account)
        allow(razorpay_service).to receive(:create_subscription).and_return(nil)

        post "/bx_block_razorpay/payments/create_subscription",
             params: { id: plan.id, auto_renew: true },
             headers: { 'token' => token },
             as: :json
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "error" => "Failed to create subscription" })
      end
    end
  end
end
