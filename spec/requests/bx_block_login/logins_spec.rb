
require 'rails_helper'

RSpec.describe BxBlockLogin::LoginsController, type: :request do
  describe 'Login functionality' do
    let!(:email_account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: "Password@123", password_confirmation: "Password@123", full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
    
    let(:valid_params) do
      {
          email: email_account.email,
          password: "Password@123"
        }
      
    end
    
    let(:invalid_email_params) do
      {
          email: "nonexistent@example.com", # Email not found
          password: "Password@123"
      }
    end
    
    let(:invalid_password_params) do
      {
          email: email_account.email,
          password: "wrongpassword" # Incorrect password
        }
    end

     let(:valid_2fa_params) do
      {
        email: email_account.email,
        password: "Password@123"
      }
    end
    
    describe 'POST /bx_block_login/logins' do
      context 'with valid email and password' do
        it 'logs in the user and returns a token' do
          post '/bx_block_login/logins', params: valid_params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Login successful')
          expect(JSON.parse(response.body)['meta']['token']).not_to be_nil
          expect(JSON.parse(response.body)['meta']['account_id']).to eq(email_account.id)
        end
      end

      context 'with invalid email' do
        it 'returns an error message for email not found' do
          post '/bx_block_login/logins', params: invalid_email_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Email not found. Please check your email')
        end
      end

      context 'with incorrect password' do
        it 'returns an error message for incorrect password' do
          post '/bx_block_login/logins', params: invalid_password_params
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to include('Incorrect password. Please try again or use the Forgot Password link')
        end
      end

      context 'with two-factor authentication enabled' do
        before do
          email_account.setting.update(two_factor_enabled: true)
          allow(BxBlockSms::TwilioService).to receive(:send_sms).and_return(true)
        end

        it 'sends an OTP to the user\'s phone number' do
          post '/bx_block_login/logins', params: valid_2fa_params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('A verification code has been sent to your mobile number.')
        end
      end
    end
  end
end
