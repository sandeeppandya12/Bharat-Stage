require 'rails_helper'

RSpec.describe BxBlockNotifications::NotificationsController, type: :controller do
  PASSWORD = "Password@123".freeze
  let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
  let!(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }

  let!(:notification1) { BxBlockNotifications::Notification.create(account: account, read_at: DateTime.now, headings: "verify user", contents: "Welcome", is_read: false) }
  let!(:notification2) { BxBlockNotifications::Notification.create(account: account, is_read: false, read_at: DateTime.now, headings: "verify user", contents: "filmmakers.") }

  describe "GET #index" do
  	it "returns a list of notifications" do
      get :index, params: { token: token }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["data"]).not_to be_empty
      expect(parsed_response["meta"]["message"]).to eq("List of notifications.")
    end

  	it "returns no notifications when none exist" do
      BxBlockNotifications::Notification.destroy_all
      get :index, params: { token: token }
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["errors"][0]["message"]).to eq("No notification found.")
    end  
  end

  describe "PUT #read_all_notification" do
    it "marks all notifications as read" do
      put :read_all_notification,params: { token: token }
      expect(response).to have_http_status(:ok)
      expect(account.notifications.where(is_read: false)).to be_empty
    end

    it "returns an error when there are no notifications" do
	    account.notifications.destroy_all
	    patch :read_all_notification, params: { token: token }
	    parsed_response = JSON.parse(response.body)
	    expect(response).to have_http_status(:not_found)
	    expect(parsed_response["errors"]).to eq("Notification not found")
	  end
  end

  describe "PUT #update" do
    it "returns error for non-existent notification" do
      put :update, params: { id: 9999 , token: token }
      parsed_response = JSON.parse(response.body)
		  expect(response).to have_http_status(:not_found)
		  expect(parsed_response["error"]).to eq("Notification not found")
    end

    it "marks a notification as read" do
      put :update, params: { id: notification1.id, token: token }
      expect(response).to have_http_status(:ok)
      notification1.reload
      expect(notification1.is_read).to be_truthy
    end
  end

end