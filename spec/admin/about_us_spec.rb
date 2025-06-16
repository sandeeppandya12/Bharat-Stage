require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::AboutUsController, type: :controller do
  let!(:admin_user) { FactoryBot.create(:admin_user) }
  let!(:about_us) { BxBlockTermsAndConditions::AboutUs.create(description: "About us") }
  render_views

  before do
    sign_in admin_user
  end

  describe "GET #index" do
    it "returns a successful response and shows the list of About Us" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include(about_us.description)
    end
  end

  describe "GET #show" do
    it "returns a successful response and displays the About Us details" do
      get :show, params: { id: about_us.id }
      expect(response).to be_successful
      expect(assigns(:about_us)).to eq(about_us)
    end
  end

  describe "POST #create" do
    it "creates a new About Us" do
      expect {
        post :create, params: { about_us: { description: "New About Us Description" } }
      }.to change(BxBlockTermsAndConditions::AboutUs, :count).by(1)
      expect(flash[:notice]).to eq("About us was successfully created.")
    end
  end

  describe "PATCH #update" do
    it "updates an existing About Us" do
      patch :update, params: { id: about_us.id, about_us: { description: "Updated Description" } }
      
      about_us.reload
      expect(about_us.description).to eq("Updated Description")
      expect(flash[:notice]).to eq("About us was successfully updated.")
    end
  end
end
