require 'rails_helper'

module BxBlockCometchatintegration
  RSpec.describe CometChatService, type: :service do
    let(:uid) { '12345' }
    let(:name) { 'Test User' }
    let(:api_key) { ENV['COMETCHAT_API_KEY'] }

    describe '.create_user' do
      it 'creates a user successfully' do
        response = { 'data' => { 'uid' => uid, 'name' => name } }

        allow(CometChatService).to receive(:post).and_return(double(parsed_response: response))

        result = CometChatService.create_user(uid, name)
        expect(result['data']['uid']).to eq(uid)
        expect(result['data']['name']).to eq(name)
      end
    end

    describe '.generate_auth_token' do
      it 'generates an auth token successfully' do
        response = { 'data' => { 'authToken' => 'auth_token_value', 'uid' => uid } }

        allow(CometChatService).to receive(:post).and_return(double(parsed_response: response))

        result = CometChatService.generate_auth_token(uid)
        expect(result['data']['authToken']).to eq('auth_token_value')
        expect(result['data']['uid']).to eq(uid)
      end
    end
  end
end
