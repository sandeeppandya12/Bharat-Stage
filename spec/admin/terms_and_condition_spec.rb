require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::TermsAndConditionsController, type: :controller do
  let!(:admin_user) { FactoryBot.create(:admin_user) }
  let!(:terms) { FactoryBot.create(:terms_and_conditions) }
  render_views
  
  before do
    sign_in admin_user  # Simulate user sign-in using Devise helper
  end

  describe "GET #index" do
    it "returns a successful response and lists terms and conditions" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include(terms.description)
    end
  end

  describe "GET #show" do
    it "returns a successful response and shows a specific term and condition" do
      get :show, params: { id: terms.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(terms.title)
      expect(response.body).to include(terms.description)
    end
  end

  describe "POST #create" do
    it "creates a new term and condition" do
      BxBlockTermsAndConditions::TermsAndCondition.destroy_all
      expect {
        post :create, params: { 
          terms_and_condition: { title: "New Terms", description: "New Description" } 
        }
      }.to change(BxBlockTermsAndConditions::TermsAndCondition, :count).by(1)

      expect(flash[:notice]).to eq("Terms and condition was successfully created.")
    end
  end
  
  describe "PATCH #update" do
    it "updates an existing term and condition" do
      patch :update, params: { 
        id: terms.id, 
        terms_and_condition: { title: "Updated Title", description: "Updated Description" } 
      }
      
      terms.reload
      expect(terms.title).to eq("Updated Title")
      expect(terms.description).to eq("Updated Description")
      expect(flash[:notice]).to eq("Terms and condition was successfully updated.")
    end
  end
end
