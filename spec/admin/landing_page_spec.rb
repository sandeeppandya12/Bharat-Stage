require 'rails_helper'

RSpec.describe Admin::LandingPagesController, type: :controller do
  render_views

  before(:each) do
    @user = FactoryBot.create(:admin_user)
    sign_in @user
  end
  BxBlockContentManagement::LandingPage.destroy_all
  let!(:landing_page) { BxBlockContentManagement::LandingPage.create!(title: "Sample Title", description: "Sample Content") }
  let!(:landing_page2) { BxBlockContentManagement::LandingPage.create!(title: "Sample Title2", description: "Sample Content2", image: fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')) }

  describe "GET #show" do
    it "returns a successful response and displays the landing details" do
      get :show, params: { id: landing_page2.id }
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(landing_page2.title)
      expect(response.body).to include(landing_page2.description)
      expect(response.body).to include('girl.jpeg')
    end

    it "returns a successful response and displays the landing details" do
      get :show, params: { id: landing_page.id }
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(landing_page.title)
      expect(response.body).to include(landing_page.description)
      expect(response.body).to include('No Image')
    end
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(landing_page.title)
      expect(response.body).to include(landing_page.description)
    end
  end

  describe "POST #create" do
    it "updates an existing landing_page" do
      patch :edit, params: { id: landing_page.id, landing_page: {  title: "Sample Title", description: "Updated Description" } }
      
      landing_page.reload
      expect(landing_page.description).to eq("Sample Content")
    end

  end
end
