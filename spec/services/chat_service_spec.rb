require 'rails_helper'

RSpec.describe BxBlockCometchatintegration::ChatService, type: :service do

  SUCCESS = '{"success": true}'
  IMAGE = 'http://example.com/media/image.jpg'
  let(:sender_uid) { 'sender123' }
  let(:receiver_uid) { 'receiver456' }
  let(:message) { 'Hello, how are you?' }
  let(:message_id) { 'message789' }
  let(:conversation_id) { 'conversation123' }
  let(:on_behalf_of_id) { 'user_456' }
  let(:search_query) { 'query' }
  let(:response_body) { '{"conversations": []}' }  # Mock response for fetch_conversations
  let(:mock_response) { double('HTTParty::Response', code: 200, body: response_body) }
  let(:http_double) { instance_double(Net::HTTP) }
  let(:request_double) { instance_double(Net::HTTP::Post) }
  let(:response_double) { instance_double(Net::HTTPResponse, code: '200', body: SUCCESS) }
  let(:media_file) { instance_double('ActionDispatch::Http::UploadedFile', 
                                    original_filename: 'image.jpg', 
                                    content_type: 'image/jpeg', 
                                    size: 1234567, 
                                    tempfile: StringIO.new("file content")) }

  before do
    allow(Net::HTTP).to receive(:new).and_return(http_double)
    allow(http_double).to receive(:use_ssl=)
    allow(http_double).to receive(:request).and_return(response_double)
    allow(Net::HTTP::Post).to receive(:new).and_return(request_double)
    allow(request_double).to receive(:[]=)
    allow(request_double).to receive(:body=)
    allow(Net::HTTP::Delete).to receive(:new).and_return(request_double)
    s3_client_double = instance_double(Aws::S3::Client)
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client_double)

    # Stub `put_object` to avoid actual S3 calls and simulate the file upload process
    allow(s3_client_double).to receive(:put_object).and_return(nil)  # Do nothing and return nil

    # Ensure that the upload function returns a mock URL
    allow(BxBlockCometchatintegration::ChatService).to receive(:upload_media_to_minio).and_return(IMAGE)
  end

  describe '.send_message' do
    it 'sends a message successfully' do
      expect(Net::HTTP).to receive(:new).and_return(http_double)
      expect(http_double).to receive(:request).and_return(response_double)
      expect(response_double).to receive(:code).and_return('200')
      expect(response_double).to receive(:body).and_return(SUCCESS)
      response = BxBlockCometchatintegration::ChatService.send_message(sender_uid, receiver_uid, message)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end

    it 'uploads the image and sends the message successfully' do
      # Ensure the media upload function is called
      expect(BxBlockCometchatintegration::ChatService).to receive(:upload_media_to_minio).with(media_file).and_return(IMAGE)

      # Mock the Net::HTTP request behavior
      expect(Net::HTTP).to receive(:new).and_return(http_double)
      expect(http_double).to receive(:request).and_return(response_double)
      expect(response_double).to receive(:code).and_return('200')
      expect(response_double).to receive(:body).and_return(SUCCESS)
      response = BxBlockCometchatintegration::ChatService.send_message(sender_uid, receiver_uid, message, media_file)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

  describe '.upload_media_to_minio' do
    it 'stubs the upload process and returns the correct file URL' do
      s3_client_double = instance_double(Aws::S3::Client)
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client_double)
      allow(s3_client_double).to receive(:put_object).and_return(nil)
      file_url = BxBlockCometchatintegration::ChatService.upload_media_to_minio(media_file)
      expect(file_url).to eq(IMAGE)
    end
  end

  describe '.get_user_conversation' do
    it 'retrieves user conversations' do
      allow(http_double).to receive(:request).and_return(response_double)
      expect(Net::HTTP::Get).to receive(:new).and_return(request_double)
      allow(URI).to receive(:parse).and_return(URI("#{ENV['COMET_CHAT_URL']}/messages?limit=100"))
      response = BxBlockCometchatintegration::ChatService.get_user_conversation(sender_uid)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

  describe '.mark_as_delivered' do
    it 'marks messages as delivered' do
      expect(http_double).to receive(:request).and_return(response_double)
      response = BxBlockCometchatintegration::ChatService.mark_as_delivered(sender_uid, receiver_uid)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

  describe '.mark_as_read' do
    it 'marks messages as read' do
      expect(http_double).to receive(:request).and_return(response_double)
      response = BxBlockCometchatintegration::ChatService.mark_as_read(sender_uid, receiver_uid)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

  describe '.block_user' do
    it 'blocks a user successfully' do
      expect(Net::HTTP).to receive(:new).and_return(http_double)
      expect(http_double).to receive(:request).and_return(response_double)
      expect(response_double).to receive(:code).and_return('200')
      expect(response_double).to receive(:body).and_return(SUCCESS)
      response = BxBlockCometchatintegration::ChatService.block_user(sender_uid, receiver_uid)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

  describe '.unblock_user' do
    it 'unblocks a user successfully' do
      expect(Net::HTTP).to receive(:new).and_return(http_double)
      expect(http_double).to receive(:request).and_return(response_double)
      expect(response_double).to receive(:code).and_return('200')
      expect(response_double).to receive(:body).and_return(SUCCESS)
      response = BxBlockCometchatintegration::ChatService.unblock_user(sender_uid, receiver_uid)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

  describe '.delete_message' do
    it 'deletes a message successfully' do
      expect(Net::HTTP).to receive(:new).and_return(http_double)
      expect(http_double).to receive(:request).and_return(response_double)
      expect(response_double).to receive(:code).and_return('200')
      expect(response_double).to receive(:body).and_return(SUCCESS)
      response = BxBlockCometchatintegration::ChatService.delete_message(message_id, sender_uid)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

  describe '.fetch_conversations' do
    it 'fetches conversations successfully' do
      allow(http_double).to receive(:request).and_return(response_double)
      expect(Net::HTTP::Get).to receive(:new).and_return(request_double)
      allow(URI).to receive(:parse).and_return(URI("#{ENV['COMET_CHAT_URL']}/users/#{sender_uid}/conversations"))
      expect(request_double).to receive(:[]=).with("onBehalfOf", sender_uid)
      response = BxBlockCometchatintegration::ChatService.fetch_conversations(sender_uid, search_query)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

  describe '.get_all_chat' do
    it 'fetches all chats successfully' do
      allow(http_double).to receive(:request).and_return(response_double)
      expect(Net::HTTP::Get).to receive(:new).and_return(request_double)
      allow(URI).to receive(:parse).and_return(URI("#{ENV['COMET_CHAT_URL']}/conversations?conversationType=user"))
      expect(request_double).to receive(:[]=).with("onBehalfOf", on_behalf_of_id)
      response = BxBlockCometchatintegration::ChatService.get_all_chat(on_behalf_of_id)
      expect(response.code).to eq('200')
      expect(response.body).to eq(SUCCESS)
    end
  end

   describe '.delete_user_conversation' do
    it 'successfully deletes a conversation' do
      expect(Net::HTTP).to receive(:new).and_return(http_double)
      expect(http_double).to receive(:request).and_return(response_double)
      expect(response_double).to receive(:code).and_return('200')
      expect(response_double).to receive(:body).and_return(response_body)
      response = BxBlockCometchatintegration::ChatService.delete_user_conversation(conversation_id)
      expect(response.code).to eq('200')
      expect(response.body).to eq(response_body)
    end

    it 'returns an error when the request fails' do
      failed_response = instance_double(Net::HTTPResponse, code: '500', body: '{"status": "error"}')
      allow(http_double).to receive(:request).and_return(failed_response)
      response = BxBlockCometchatintegration::ChatService.delete_user_conversation(conversation_id)
      expect(response.code).to eq('500')
      expect(response.body).to eq('{"status": "error"}')
    end
  end

    describe '.update_user_profile_name' do
    let(:user_id) { 'user_123' }
    let(:full_name) { 'New User Name' }
    let(:update_response_body) { '{"success": true, "message": "User updated"}' }
    let(:put_request_double) { instance_double(Net::HTTP::Put) }

    before do
      allow(Net::HTTP::Put).to receive(:new).and_return(put_request_double)
      allow(put_request_double).to receive(:[]=)
      allow(put_request_double).to receive(:body=)
      allow(http_double).to receive(:request).and_return(response_double)
      allow(response_double).to receive(:code).and_return('200')
      allow(response_double).to receive(:body).and_return(update_response_body)
    end

    it 'successfully updates user profile name' do
      expect(Net::HTTP).to receive(:new).and_return(http_double)
      expect(http_double).to receive(:request).and_return(response_double)
      response = BxBlockCometchatintegration::ChatService.update_user_profile_name(user_id, full_name)
      expect(response.code).to eq('200')
      expect(response.body).to eq(update_response_body)
    end

    it 'logs an error if the request fails' do
      allow(http_double).to receive(:request).and_raise(StandardError.new("Request failed"))
      expect(Rails.logger).to receive(:error).with(/CometChat name update failed/)
      expect {
        BxBlockCometchatintegration::ChatService.update_user_profile_name(user_id, full_name)
      }.not_to raise_error
    end
  end
end