require 'rails_helper'

RSpec.describe BxBlockOrderManagement::SubScriptionOrdersController, type: :controller do
  let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: "Password@123", password_confirmation: "Password@123", full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
  let(:subscription_free) { BxBlockCustomUserSubs::Subscription.create(name: 'free', price: 0) }
  let(:subscription_monthly) {  BxBlockCustomUserSubs::Subscription.create(name: 'monthly', price: 100) }
  let(:subscription_yearly) {  BxBlockCustomUserSubs::Subscription.create(name: 'yearly', price: 1000) }
  let(:subcription_order) {FactoryBot.create(:sub_scription_order, account_id: account.id, subscription_id: subscription_monthly.id)}
  let(:subcription_order1) {FactoryBot.create(:sub_scription_order, account_id: account.id, subscription_id: subscription_yearly.id, active_plan: true)}

  let!(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }

  before do
   request.headers['token'] = token
  end

  describe 'GET #index' do
    context 'when subscription is free' do
      before do
        get :index, params: { subscription_id: subscription_free.id }
      end

      it 'returns a success response with free plan details' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to include("Congratulations! Your free plan has started")
      end

      before do
        subcription_order.reload
      end

       it 'returns an error for allready subscribed plan' do
        get :index, params: { subscription_id: subscription_free.id }
        expect(JSON.parse(response.body)['error']).to eq("You have already subscribed to the free plan.")
      end

      before do
        subcription_order1.reload
      end

       it 'returns an error for plan' do
        get :index, params: { subscription_id: subscription_monthly.id }
        expect(JSON.parse(response.body)['error']).to eq("your plan is active you con't buy a new plan")
      end
    end

    context 'when subscription is monthly' do
      it 'creates a subscription order successfully' do
        expect {
          get :index, params: { subscription_id: subscription_monthly.id }
        }.to change(BxBlockOrderManagement::SubScriptionOrder, :count).by(1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']['status']).to eq('pending')
        expect(json_response['data'].count).to eq(3)
      end
    end

    context 'when subscription is not found' do
      it 'returns an error' do
        get :index, params: { subscription_id: 99999 }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Subscription not found')
      end
    end
  end

  describe 'GET #user_current_plan' do
    context 'When subscription is free' do
      it 'returns an error for plan not found' do
        get :user_current_plan
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('User current plan not found.')
      end
    end
  end

   describe 'GET #user_all_plans' do
    context 'When subscription is free' do
      it 'return an error' do
        get :user_all_plans
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq("Plan not found.")
      end
    end
  end
end
