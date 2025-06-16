require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::SubscriptionsController, type: :controller do
  let!(:admin_user) { FactoryBot.create(:admin_user) }
  let!(:subscription_plan) { BxBlockCustomUserSubs::Subscription.create(price: 10, name: "Monthly") }
  
  render_views
  
  before do
    sign_in admin_user 
  end

  describe "GET #show" do
    it "returns a successful response and shows a specific subscription" do
      get :show, params: { id: subscription_plan.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(subscription_plan.name)
    end
  end

  describe "GET #index" do
    it "returns a successful response and lists subscriptions" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include(subscription_plan.name)
    end
  end

  describe "POST #create" do
    it "creates a new subscription" do
      expect {
        post :create, params: { subscription: { price: 50, name: "Yearly" } }
      }.to change(BxBlockCustomUserSubs::Subscription, :count).by(0)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update" do
    let(:razorpay_service) { instance_double(BxBlockRazorpay::RazorpayIntegration) }

    before do
      allow(BxBlockRazorpay::RazorpayIntegration).to receive(:new).and_return(razorpay_service)
      allow(razorpay_service).to receive(:create_plan).and_return("razorpay_plan_123")
    end

    it "updates the subscription and creates a Razorpay plan" do
      patch :update, params: { id: subscription_plan.id, subscription: { price: 20 } }
      subscription_plan.reload

      expect(subscription_plan.price).to eq(20)
      expect(subscription_plan.razorpay_plan_id).to eq("razorpay_plan_123")
      expect(response).to redirect_to(admin_subscription_path(subscription_plan))
      expect(flash[:notice]).to eq("Price updated and Razorpay plan created!")
    end

    it "returns an error if subscription type is unsupported" do
      subscription_plan.update(name: "Weekly")

      expect {
        patch :update, params: { id: subscription_plan.id, subscription: { price: 30 } }
      }.to raise_error("Unsupported subscription type")
    end

    it "renders edit on update failure" do
      allow_any_instance_of(BxBlockCustomUserSubs::Subscription).to receive(:update).and_return(false)

      patch :update, params: { id: subscription_plan.id, subscription: { price: 50 } }

      expect(response).to render_template(:edit)
    end
  end
end
