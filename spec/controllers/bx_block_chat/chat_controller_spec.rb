require 'rails_helper'

RSpec.describe BxBlockChat::ChatsController, type: :controller do
  let!(:account) { create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: "Password@123", password_confirmation: "Password@123", full_phone_number: '+919999999999', terms_accepted: true, activated: true, comet_chat_uid: "10") }
  let(:token) { BuilderJsonWebToken.encode(account.id, 2.days.from_now, token_type: 'login') }
  let(:valid_headers) { { "Authorization" => "Bearer #{token}" } }

  HTTP_RESPONSE = "HTTParty::Response"
  NAME = "John Doe"

  before do
    request.headers.merge!(valid_headers)
    allow(controller).to receive(:validate_json_web_token).and_return(true)
    @current_user = account
    controller.instance_variable_set(:@current_user, @current_user)
    allow(controller).to receive(:set_account).and_return(@current_user)
  end

  describe "POST #send_message" do
    let(:sender_uid) { account.comet_chat_uid }
    let(:receiver_uid) { "user_2" }
    let(:message) { "Hello, how are you?" }
    let(:chat_service_response) { instance_double(HTTP_RESPONSE, body: { "status" => "success", "message_id" => "12345" }.to_json) }
    let(:image) { fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg') }

    context "with valid params" do
      before do
        # Mock the service call response
        allow(BxBlockCometchatintegration::ChatService).to receive(:send_message).and_return(chat_service_response)
        BxBlockNotifications::Notification.create(
        account_id: receiver_uid,     
        read_at: DateTime.now,
        contents: "sent you a message.")
        post :send_message, params: { sender_uid: sender_uid, receiver_uid: receiver_uid, message: message, media_file: image }
      end

      it "calls the ChatService method with correct parameters" do
        expect(BxBlockCometchatintegration::ChatService).to have_received(:send_message).with(sender_uid, receiver_uid, message, kind_of(ActionDispatch::Http::UploadedFile))
      end

      it "returns a successful response for correct parameters" do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response["data"]["status"]).to eq("success")
      end
    end

    context "with missing parameters" do
      before do
        post :send_message, params: { receiver_uid: ' ', message: message }
      end

      it "returns a bad request response" do
        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to include("error")
      end
    end

    context "when user try to message to own account" do
      before do
        post :send_message, params: { receiver_uid: sender_uid, message: message }
      end

      it "returns a bad request response with error" do
        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to include("error")
      end
    end
  end

  describe "POST #mark_as_delivered" do
    let(:sender_uid) { account.comet_chat_uid }
    let(:receiver_uid) { "user_2" }
    let(:chat_service_response) { instance_double(HTTP_RESPONSE, body: { "status" => "delivered" }.to_json) }

    before do
      allow(BxBlockCometchatintegration::ChatService).to receive(:mark_as_delivered).and_return(chat_service_response)
      post :mark_as_delivered, params: { sender_uid: sender_uid, receiver_uid: receiver_uid }
    end

    it "calls the ChatService to mark as delivered" do
      expect(BxBlockCometchatintegration::ChatService).to have_received(:mark_as_delivered).with(sender_uid, receiver_uid)
    end

    it "returns a successful response for mark as delivered" do
      parsed_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_response["data"]["status"]).to eq("delivered")
    end
  end

  describe "POST #mark_as_read" do
    let(:sender_uid) { account.comet_chat_uid }
    let(:receiver_uid) { "user_2" }
    let(:chat_service_response) { instance_double(HTTP_RESPONSE, body: { "status" => "read" }.to_json) }

    before do
      allow(BxBlockCometchatintegration::ChatService).to receive(:mark_as_read).and_return(chat_service_response)
      post :mark_as_read, params: { sender_uid: sender_uid, receiver_uid: receiver_uid }
    end

    it "calls the ChatService to mark as read" do
      expect(BxBlockCometchatintegration::ChatService).to have_received(:mark_as_read).with(sender_uid, receiver_uid)
    end

    it "returns a successful response for mark as read" do
      parsed_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_response["data"]["status"]).to eq("read")
    end
  end

  describe "POST #block_user" do
    let(:receiver_uid) { "user_2" }
    let(:chat_service_response) { instance_double(HTTP_RESPONSE, body: { "status" => "blocked" }.to_json) }

    before do
      allow(BxBlockCometchatintegration::ChatService).to receive(:block_user).and_return(chat_service_response)
      post :block_user, params: { receiver_uid: receiver_uid }
    end

    it "calls the ChatService to block the user" do
      expect(BxBlockCometchatintegration::ChatService).to have_received(:block_user).with(@current_user.comet_chat_uid, receiver_uid)
    end

    it "returns a successful response for block user" do
      parsed_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_response["data"]["status"]).to eq("blocked")
    end
  end

  describe "POST #unblock_user" do
    let(:receiver_uid) { "user_2" }
    let(:chat_service_response) { instance_double(HTTP_RESPONSE, body: { "status" => "unblocked" }.to_json) }

    before do
      allow(BxBlockCometchatintegration::ChatService).to receive(:unblock_user).and_return(chat_service_response)
      post :unblock_user, params: { receiver_uid: receiver_uid }
    end

    it "calls the ChatService to unblock the user" do
      expect(BxBlockCometchatintegration::ChatService).to have_received(:unblock_user).with(@current_user.comet_chat_uid, receiver_uid)
    end

    it "returns a successful response for unblock user" do
      parsed_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_response["data"]["status"]).to eq("unblocked")
    end
  end

  describe "POST #delete_message" do
    let(:message_id) { "12345" }
    let(:chat_service_response) { instance_double(HTTP_RESPONSE, body: { "status" => "deleted" }.to_json) }

    before do
      allow(BxBlockCometchatintegration::ChatService).to receive(:delete_message).and_return(chat_service_response)
      post :delete_message, params: { message_id: message_id }
    end

    it "calls the ChatService to delete the message" do
      expect(BxBlockCometchatintegration::ChatService).to have_received(:delete_message).with(message_id, @current_user.comet_chat_uid)
    end

    it "returns a successful response for delete message" do
      parsed_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_response["data"]["status"]).to eq("deleted")
    end
  end

  describe "GET #search_conversations" do
    let(:search_query) { "John" }
    let(:sender_uid) { account.comet_chat_uid }
    let(:chat_service_response) do
      instance_double(
        HTTP_RESPONSE,
        body: { "data" => [{"conversationWith" => {"name" => NAME}}] }.to_json,
        code: 200 
      )
    end

    context "with valid search query" do
      before do
        allow(BxBlockCometchatintegration::ChatService).to receive(:fetch_conversations).and_return(chat_service_response)
        get :search_conversations, params: { search_query: search_query, token: token }
      end

      it "calls the ServiceFile with correct parameters" do
        expect(BxBlockCometchatintegration::ChatService).to have_received(:fetch_conversations).with(sender_uid, search_query)
      end

      it "returns a successful response with the filtered conversations" do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response["data"].first["conversationWith"]["name"]).to eq(NAME)
      end
    end

    context "with empty search query" do
      before do
        get :search_conversations, params: { search_query: '', token: token }
      end

      it "returns a bad request response" do
        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to include("error")
      end
    end

    context "when no conversations match the search" do
      let(:chat_service_response) { instance_double(HTTP_RESPONSE, body: { "data" => [] }.to_json, code: 200) }

      before do
        allow(BxBlockCometchatintegration::ChatService).to receive(:fetch_conversations).and_return(chat_service_response)
        get :search_conversations, params: { search_query: search_query, token: token }
      end

      it "returns an empty data array" do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response["data"]).to eq([])
      end
    end
  end

  describe "GET #chat_history" do
    let(:sender_uid) { account.comet_chat_uid }
    let(:on_behalf_of_id) { account.comet_chat_uid }

    let(:chat_history_service_response) do
      instance_double(
        HTTP_RESPONSE,
        body: { "data" => [{"conversationWith" => {"name" => NAME}, "messages" => ["message1", "message2"]}] }.to_json,
        code: 200 
      )
    end

    context "when valid request" do
      before do
        allow(BxBlockCometchatintegration::ChatService).to receive(:get_all_chat).and_return(chat_history_service_response)
        get :chat_history, params: { on_behalf_of_id: on_behalf_of_id, token: token }
      end

      it "calls the ChatService with correct parameters" do
        expect(BxBlockCometchatintegration::ChatService).to have_received(:get_all_chat).with(on_behalf_of_id)
      end

      it "returns a successful response with chat history data" do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response["data"]['data'][0]['conversationWith']['name']).to eq(NAME)
      end
    end

    context "when no chat history available" do
      let(:chat_history_service_response) { instance_double(HTTP_RESPONSE, body: { "data" => [] }.to_json, code: 200) }

      before do
        allow(BxBlockCometchatintegration::ChatService).to receive(:get_all_chat).and_return(chat_history_service_response)
        get :chat_history, params: { on_behalf_of_id: on_behalf_of_id, token: token }
      end

      it "returns an empty data array" do
        parsed_response = JSON.parse(response.body)
        expect(response.code.to_i).to eq(200)
        expect(parsed_response["data"]['data']).to eq([])
      end
    end
  end

  describe "DELETE #delete_conversation" do
    let(:conversation_id) { "12345" }
    let(:chat_service_response) { instance_double(HTTP_RESPONSE, body: { "status" => "deleted", "message" => "Conversation deleted successfully" }.to_json) }

    context "with valid conversation_id" do
      before do
        allow(BxBlockCometchatintegration::ChatService).to receive(:delete_user_conversation).and_return(chat_service_response)
        delete :delete_conversation, params: { conversation_id: conversation_id }
      end

      it "calls the ChatService method with the correct parameters" do
        expect(BxBlockCometchatintegration::ChatService).to have_received(:delete_user_conversation).with(conversation_id)
      end

      it "returns a successful response for valid conversation_id" do
        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response["data"]["status"]).to eq("deleted")
        expect(parsed_response["data"]["message"]).to eq("Conversation deleted successfully")
      end
    end

    context "with missing conversation_id" do
      before do
        delete :delete_conversation, params: { conversation_id: '' }
      end

      it "returns a bad request" do
        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to include("error")
        expect(parsed_response["error"]).to eq("conversations id are required")
      end
    end
  end

  describe 'GET chats' do
    let(:valid_headers) do
      {
        'Authorization' => "Bearer #{BuilderJsonWebToken.encode(account.id)}"
      }
    end
    context 'when chat not exist' do
      it 'returns all not found message ' do
        get :index, params: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)          
        json_response = JSON.parse(response.body)
        expect(json_response['user_chats']).to eq('not found')
      end
    end
  end
end