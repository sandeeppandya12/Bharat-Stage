require 'rails_helper'
RSpec.describe BxBlockRazorpayWebhook::RazorpayWebhooksController, type: :controller do
  PASSWORD = "Password@123".freeze
  FULL_PHONE_NUMBER = 9129929600.freeze

  let!(:account) do
    FactoryBot.create(
      :account,
      email: "user_#{SecureRandom.hex(10)}@example.com",
      password: PASSWORD,
      password_confirmation: PASSWORD,
      full_phone_number: FULL_PHONE_NUMBER,
      terms_accepted: true,
      activated: true
    )
  end

  let!(:token) { BuilderJsonWebToken.encode(account.id, 2.days.from_now, token_type: 'login') }

  let!(:plan) { BxBlockCustomUserSubs::Subscription.create(name: "Yearly", price: 500, description: 'hello') }

  let!(:razorpay_service) { instance_double(BxBlockRazorpay::RazorpayIntegration) }

  before do
    allow(BxBlockRazorpay::RazorpayIntegration).to receive(:new).and_return(razorpay_service)
    account # Explicitly reference account to ensure it's evaluated
    BxBlockOrderManagement::SubScriptionOrder.create(
      account_id: account.id,
      subscription_id: plan.id,
      order_date: Time.current,
      active_plan: true
    )
  end

  let(:valid_signature) { 'valid_signature_from_razorpay' }
  let(:invalid_signature) { 'invalid_signature' }

  let(:valid_payload) do
    {
      "event" => "payment.captured",
      "payload" => {
        "payment" => {
          "entity" => {
            "id" => "pay_1D2Hc0Lz123456",
            "amount" => 100,
            "customer_id" => account.razorpay_customer_id
          }
        }
      }
    }.to_json
  end

  before do
    allow(OpenSSL::HMAC).to receive(:hexdigest).and_return(valid_signature)
    request.headers['X-Razorpay-Signature'] = valid_signature
  end
  
  describe 'POST #receive' do
    context 'when signature is valid' do
      it 'responds with success for payment.captured' do
        post :receive, body: valid_payload

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end

      it 'activates subscription for existing plan' do
        unique_plan_id = "plan_#{SecureRandom.hex(4)}"
          subscription = BxBlockCustomUserSubs::Subscription.create!(
            name: "Yearly", 
            price: 500, 
            description: 'hello', 
            razorpay_plan_id: unique_plan_id
          )

        payload = {
          "event" => "subscription.activated",
          "payload" => {
            "payment" => {
              "entity" => {
                "id" => "pay_1D2Hc0Lz123456",
                "amount" => 100,
                "customer_id" => account.razorpay_customer_id
              }
            },
            "subscription" => {
              "entity" => {
                "id" => "sub_test123",
                "plan_id" => subscription.razorpay_plan_id
              }
            }
          }
        }.to_json


        allow(controller).to receive(:handle_subscription_activated).and_call_original

        post :receive, body: payload

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["status"]).to eq("success")
      end

      it 'responds with success for subscription.charged' do
        payload = {
          "event" => "subscription.charged",
          "payload" => {
            "subscription" => {
              "id" => "sub_1D2Hc0Lz123457"
            }
          }
        }.to_json

        expect(controller).to receive(:handle_subscription_charged).with(instance_of(Hash))

        post :receive, body: payload

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end

      it 'responds with success for payment.authorized' do
        payload = {
          "event" => "payment.authorized",
          "payload" => {
            "payment" => {
              "id" => "pay_1D2Hc0Lz123457",
              "amount" => 200
            }
          }
        }.to_json

        expect(controller).to receive(:handle_payment_authenticated).with(instance_of(Hash))

        post :receive, body: payload

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end
  
      it 'responds with success for subscription.cancelled' do
        payload = {
          "event" => "subscription.cancelled",
          "payload" => {
            "subscription" => {
              "id" => "sub_1D2Hc0Lz123458"
            }
          }
        }.to_json

        expect(controller).to receive(:handle_subscription_cancelled).with(instance_of(Hash))
        
        post :receive, body: payload

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end
  
      it 'responds with success for payment.failed' do
        payload = {
          "event" => "payment.failed",
          "payload" => {
            "payment" => {
              "id" => "pay_1D2Hc0Lz123459",
              "amount" => 300
            }
          }
        }.to_json

        expect(controller).to receive(:handle_payment_failed).with(instance_of(Hash))
     
        post :receive, body: payload

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end

      it 'logs unhandled event type and responds with success' do
        payload = {
          "event" => "some.unknown.event",
          "payload" => {}
        }.to_json

        allow(Rails.logger).to receive(:info).and_call_original

        post :receive, body: payload

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('success')

        expect(Rails.logger).to have_received(:info).with("Unhandled event type: some.unknown.event")
      end
    end
  
    context 'when signature is invalid' do
      it 'responds with unauthorized' do
        request.headers['X-Razorpay-Signature'] = invalid_signature
        post :receive, body: valid_payload

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid webhook signature')
      end
    end
  end
end
  