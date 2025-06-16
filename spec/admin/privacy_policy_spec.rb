require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::PrivacyPoliciesController, type: :controller do
  let!(:admin_user) { FactoryBot.create(:admin_user) }
  let!(:privacy_policy) { FactoryBot.create(:privacy_policy) }
  render_views

  before do
    sign_in admin_user  # Devise helper to sign in the admin user
  end

  describe "GET #index" do
    it "returns a successful response and lists privacy policies" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include(privacy_policy.description)
    end
  end

  describe "GET #show" do
    it "returns a successful response and shows a specific privacy policy" do
      get :show, params: { id: privacy_policy.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(privacy_policy.title)
      expect(response.body).to include(privacy_policy.description)
    end
  end

  describe "POST #create" do
    it "creates a new privacy policy" do
      BxBlockTermsAndConditions::PrivacyPolicy.destroy_all
      expect {
        post :create, params: { 
          privacy_policy: { title: "New Privacy Policy", description: "New Privacy Policy Description" } 
        }
      }.to change(BxBlockTermsAndConditions::PrivacyPolicy, :count).by(1)
      
      expect(flash[:notice]).to eq("Privacy policy was successfully created.")
    end
  end

  describe "PATCH #update" do
    it "updates an existing privacy policy" do
      patch :update, params: { 
        id: privacy_policy.id, 
        privacy_policy: { title: "Updated Title", description: "Updated Description" } 
      }
      
      privacy_policy.reload
      expect(privacy_policy.title).to eq("Updated Title")
      expect(privacy_policy.description).to eq("Updated Description")
      expect(flash[:notice]).to eq("Privacy policy was successfully updated.")
    end
  end
end
