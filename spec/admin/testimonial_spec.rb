require 'rails_helper'

RSpec.describe Admin::TestimonialsController, type: :controller do
  render_views

  before(:each) do
    @user = FactoryBot.create(:admin_user)
    BxBlockContentManagement::Testimonial.destroy_all
    sign_in @user
  end

  describe "GET #index" do
    it "returns response" do
      @testimonial = BxBlockContentManagement::Testimonial.create!(name: "Sample Title", profile_image: fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'), designation: "Sample Content", content: "content hi")
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(@testimonial.name)
      expect(response.body).to include(@testimonial.designation)
    end
  end

  describe "GET #show" do
    it "returns a successful response and displays the content details" do
      BxBlockContentManagement::Testimonial.destroy_all
      testimonial = BxBlockContentManagement::Testimonial.create!(name: "Sample Title", designation: "Sample Content", content: "content hi", profile_image: fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'))

      get :show, params: { id: testimonial.id }
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(testimonial.name)
      expect(response.body).to include(testimonial.designation)
    end
  end

  describe "POST #create" do
    it "creates a new content and redirects to index page" do
      BxBlockContentManagement::Testimonial.destroy_all

      expect {
        post :create, params: {
          testimonial: {
            name: "Sample Title", 
            designation: "Sample Content", 
            content: "content hi",
            profile_image: fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'),
          }
        }
      }.to change(BxBlockContentManagement::Testimonial, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq('Testimonial was successfully created.')
    end

    it "maximum error message" do
      BxBlockContentManagement::Testimonial.destroy_all

      expect {
        post :create, params: {
          testimonial: {
            name: "Sample Title", 
            designation: "Sample Content", 
            content: "content hi",
            profile_image: fixture_file_upload(Rails.root.join('spec/fixtures/maximum.png'), 'image/png'),
          }
        }
      }.to change(BxBlockContentManagement::Testimonial, :count).by(0)
      expect(flash[:notice]).to eq(nil)
    end
  end

end
