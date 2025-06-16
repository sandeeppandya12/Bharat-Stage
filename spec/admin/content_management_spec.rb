require 'rails_helper'

RSpec.describe Admin::CataloguesController, type: :controller do
  render_views

  before(:each) do
    @user = FactoryBot.create(:admin_user)
    sign_in @user
  end

  describe "GET #show" do
    it "returns a successful response and displays the content details" do
      BxBlockContentManagement::ContentManagement.destroy_all
      content = BxBlockContentManagement::ContentManagement.create!(title: "Sample Title", description: "Sample Content")

      get :show, params: { id: content.id }
      
      expect(response).to have_http_status(:ok)
        expect(response.body).to include(content.title)
      expect(response.body).to include(content.description)
    end
  end

  describe "POST #create" do
    it "creates a new content and redirects to index page" do
      BxBlockContentManagement::ContentManagement.destroy_all

      expect {
        post :create, params: {
          content_management: {
            title: "New Content Title",
            description: "New Content Description",
            status: true
          }
        }
      }.to change(BxBlockContentManagement::ContentManagement, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq('Content management was successfully created.')
    end

    it "format error" do
      BxBlockContentManagement::ContentManagement.destroy_all

      expect {
        post :create, params: {
          content_management: {
            title: "New Content Title",
            description: "New Content Description",
            image: fixture_file_upload(Rails.root.join('spec/fixtures/first.mp4'), 'video/mp4') 
          }
        }
      }.to change(BxBlockContentManagement::ContentManagement, :count).by(0)
      expect(flash[:notice]).to eq(nil)
    end

     it "maximum error message" do
      BxBlockContentManagement::ContentManagement.destroy_all

      expect {
        post :create, params: {
          content_management: {
            title: "New Content Title",
            description: "New Content Description",
            image: fixture_file_upload(Rails.root.join('spec/fixtures/maximum.png'), 'image/png') 
          }
        }
      }.to change(BxBlockContentManagement::ContentManagement, :count).by(0)
      expect(flash[:notice]).to eq(nil)
    end
  end

end
