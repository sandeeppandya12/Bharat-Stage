require 'rails_helper'

RSpec.describe Admin::EmailSubscribersController, type: :controller do
  render_views

  before(:each) do
    @user = FactoryBot.create(:admin_user)
    sign_in @user
  end

  describe "GET #show" do
    it "returns a successful response and displays the content details" do
      subscribe = BxBlockContentManagement::Subscribe.create!(email: "Sample@gmail.com")
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(subscribe.email)
    end
  end
end
