require 'rails_helper'
require 'spec_helper'
include Warden::Test::Helpers

RSpec.describe Admin::DashboardController, type: :controller do
  render_views

  let!(:category_name) { Faker::Internet.name }

  before(:each) do
    @admin_user = AdminUser.find_by(email: "admin@gmail.com") || AdminUser.create(email: "admin@gmail.com", password: "123456")  
    sign_in @admin_user
  end

  describe 'GET#index' do
    it 'return message' do
      AccountBlock::Account.destroy_all
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No user registration data available.")
    end

    it 'it will show status of the dashboard page' do
      @account = FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", terms_accepted: true, full_phone_number: '+919999999900', activated: true) 
      category = BxBlockCategories::Category.create(name: category_name) 
      subcategory = BxBlockCategories::SubCategory.create!(name: 'subcategory', category_id: category.id)
      AccountBlock::AccountsSubCategory.create!(account: @account, sub_category: subcategory)
      @account.update(gender: "Male", full_phone_number: '+919999999910', languages: ["English", "French"], locations: "Madhya Pradesh")
      get :index
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end

    context 'Razorpay subscription summary' do
      it 'displays Razorpay stats when available' do
        stats = {
          total_amount: 50000,
          active_subscriptions: 15,
          monthly_count: 10,
          yearly_count: 5
        }

        allow_any_instance_of(BxBlockRazorpay::RazorpayIntegration)
          .to receive(:fetch_subscription_stats)
          .and_return(stats)

        get :index

        expect(response.body).to include("Razorpay Subscription Summary")
        expect(response.body).to include("₹50,000.00")
        expect(response.body).to include("Active Subscriptions")
        expect(response.body).to include("15")
        expect(response.body).to include("Monthly Subscriptions")
        expect(response.body).to include("10")
        expect(response.body).to include("Yearly Subscriptions")
        expect(response.body).to include("5")
      end

      it 'shows fallback message when Razorpay stats are not available' do
        allow_any_instance_of(BxBlockRazorpay::RazorpayIntegration)
          .to receive(:fetch_subscription_stats)
          .and_return(nil)

        get :index

        expect(response.body).to include("Unable to fetch subscription stats at the moment.")
      end
    end
  end

  describe 'GET #export' do
    it 'returns a successful response' do
      get :export, format: :csv
      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Type']).to include 'text/csv' 
    end

    it 'returns a CSV file with headers' do
      get :export, format: :csv
      expect(response.headers['Content-Type']).to include 'text/csv'
      expect(response.headers['Content-Disposition']).to include 'attachment; filename="user_data'
    end

    it 'includes gender data in CSV' do
      @account = FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", terms_accepted: true, full_phone_number: '+919999999100', activated: true) 
      @account.update(gender: "Male", full_phone_number: '+919999999910', languages: ["English", "French"], locations: "Madhya Pradesh")

      get :export, format: :csv
      csv = CSV.parse(response.body, headers: false)
      expect(csv.flatten).to include("Gender", "male")
    end
  end
end
