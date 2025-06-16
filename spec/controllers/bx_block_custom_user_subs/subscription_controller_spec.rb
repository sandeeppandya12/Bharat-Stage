require 'rails_helper'

RSpec.describe BxBlockCustomUserSubs::SubscriptionsController, type: :controller do

  describe 'GET #index' do
    context 'when subscription_plan is present' do
    	let!(:email_account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: "Password@123", password_confirmation: "Password@123", full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
      let!(:subscription_plan) { BxBlockCustomUserSubs::Subscription.create(price: 10, name: "Monthly") }
      let!(:token) { BuilderJsonWebToken.encode(email_account.id, 2.day.from_now, token_type: 'login') }

      before do
       request.headers['token'] = token
      end

    	it 'returns a list of all subscription_plan with status 200' do
        get :index
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].last['attributes']['name']).to eq(subscription_plan.name)
        expect(json_response['data'].last['attributes']['is_plan_used']).to eq(subscription_plan.is_plan_used)
        expect(json_response['data'].count).to eq(1)
      end
    end
  end
end