require 'rails_helper'
require 'spec_helper'
RSpec.describe BxBlockSettings::SettingsController, type: :controller do
  PASSWORD = "Password@123".freeze
  NOT_FOUND_ERROR = 'Account not found.'
  let(:account) { FactoryBot.create(:email_account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999') }
  let(:otp_record) { AccountBlock::EmailOtp.create(email: account.email, pin: '123456', valid_until: 2.hours.from_now, activated: true) }
  let(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }
  let(:token2) { BuilderJsonWebToken.encode(otp_record.id, 2.day.from_now, token_type: 'login') }

  before do
    request.headers['Authorization'] = token
  end

  describe 'POST #toggle_two_factor' do
    context 'when the account exists' do
      it 'enables two-factor authentication successfully' do
        patch :toggle_two_factor, params: { two_factor_enabled: true, token: token }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be(true)
        expect(response_body['message']).to eq('Two-Factor Authentication successfully updated.')
        expect(response_body['two_factor_enabled']).to be(true)
        expect(account.reload.setting.two_factor_enabled).to be(true)
      end

      it 'disables two-factor authentication successfully' do
        patch :toggle_two_factor, params: { two_factor_enabled: false, token: token }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be(true)
        expect(response_body['message']).to eq('Two-Factor Authentication successfully updated.')
        expect(response_body['two_factor_enabled']).to be(false)
        expect(account.reload.setting.two_factor_enabled).to be(false)
      end
    end

    context 'when the account does not exist' do
      it 'returns an error for account' do
        token = request.headers['Authorization'] = BuilderJsonWebToken.encode(9999)
        patch :toggle_two_factor, params: { two_factor_enabled: true, token: token }
        expect(response).to have_http_status(:not_found)
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be(false)
        expect(response_body['message']).to eq(NOT_FOUND_ERROR)
      end
    end

    context 'when the request is invalid' do
      it 'returns an error if two_factor_enabled is not provided' do
        post :toggle_two_factor, params: {token: token}

        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be(false)
        expect(response_body['message']).to include("Two factor enabled must be true or false")
      end
    end
  end

  describe 'PATCH #update_notification' do
    context 'when the account exists' do
      it 'updates notification settings successfully' do
        patch :update_notification, params: { 
          desktop_notification: true, 
          in_app_notification: false, 
          email_notification: true, 
          chat_notification: false, 
          token: token 
        }
        
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        
        expect(response_body['success']).to be(true)
        expect(response_body['message']).to eq('Notification settings updated successfully.')
        expect(response_body['data']['desktop_notification']).to be(true)
        expect(response_body['data']['in_app_notification']).to be(false)
        expect(response_body['data']['email_notification']).to be(true)
        expect(response_body['data']['chat_notification']).to be(false)
      end
    end

    context 'when the account does not exist' do
      it 'returns a not found error' do
        allow(AccountBlock::Account).to receive(:find_by).and_return(nil)
        
        patch :update_notification, params: { 
          desktop_notification: true, 
          in_app_notification: false, 
          email_notification: true, 
          token: token 
        }
        
        expect(response).to have_http_status(:not_found)
        response_body = JSON.parse(response.body)
        
        expect(response_body['success']).to be(false)
        expect(response_body['message']).to eq(NOT_FOUND_ERROR)
      end
    end
  end

  describe 'PATCH #update_account_profile' do
    context 'when the account update fails due to validation errors' do
      let(:invalid_params) { { first_name: '', last_name: '', roles: '', token: token } }

      it 'returns an error message for profile' do
        patch :update_account_profile, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body['errors'][0]).to include("First name can't be blank")
      end
    end
  end

  describe 'PATCH #update_account_email' do
    context 'when the email is valid and not already in use' do
      let(:new_email) { "new_user_#{SecureRandom.hex(10)}@example.com" }

      it 'updates the account email and sends OTP' do
        # Mocking EmailOtp creation and mail sending
        allow(AccountBlock::EmailOtp).to receive(:create!).and_return(double('EmailOtp', id: 1, email: new_email, activated: true))
        allow(BxBlockForgotPassword::EmailOtpMailer).to receive(:otp_email).and_return(double(deliver_now: true))

        patch :update_account_email, params: { email: new_email, token: token }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq('OTP sent to the new email. Please verify to complete the update.')
      end
    end

    context 'when the email is invalid' do
      let(:invalid_email) { 'invalid_email' }

      it 'returns an error for invalid email' do
        patch :update_account_email, params: { email: invalid_email, token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body['errors'].first['account']).to eq('Provided email address is invalid.')
      end
    end

    context 'when email parameter is missing' do
      it 'returns an error for parameter' do
        patch :update_account_email, params: {token: token}
        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body['errors'][0]['account']).to eq('Provided email address is invalid.')
      end
    end
  end

   describe 'PATCH #verify_email_otp' do
    context 'when the account cannot be found by the token' do
      it 'returns an error if the account is not found' do
        # Invalid token or missing account
        allow(AccountBlock::EmailOtp).to receive(:find_by).and_return(nil)

        patch :verify_email_otp, params: { otp: '123456', token: token }

        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Invalid or expired OTP.')
      end
    end

    context 'when OTP is invalid or expired' do
      it 'returns an error if the OTP is incorrect' do
        allow(AccountBlock::EmailOtp).to receive(:find_by).and_return(otp_record)
        patch :verify_email_otp, params: { otp: 'wrong_otp', token: token }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
      end

      it 'returns an error if the OTP is expired' do
        # Ensure correct usage of attributes that are accepted by the model
        expired_otp_record = AccountBlock::EmailOtp.create(
          email: account.email,
          pin: '123456',
          valid_until: 1.hour.ago,
          activated: true
        )

        allow(AccountBlock::EmailOtp).to receive(:find_by).and_return(expired_otp_record)

        patch :verify_email_otp, params: { otp: '123456', token: token2 }
        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq('Account not found.')
      end
    end
  end

  describe 'GET #index' do
    context 'when the settings exists' do
      it 'returns a successful response' do
        get :index, params: { token: token }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.count).to eq(1)
      end
    end
  end

  describe 'POST #update_password' do
    context 'when new password is the same as the current password' do
      it 'returns an error message for current password' do
        post :update_password, params: {
          token: token,
          current_password: account.password,
          new_password: account.password,
          password_confirmation: account.password
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Your new password must be different from your current password')
      end
    end

    context 'when new password and password confirmation do not match' do
      it 'returns an error message for password confirmation' do
        post :update_password, params: {
          token: token,
          current_password: account.password,
          new_password: 'newpassword123',
          password_confirmation: 'differentpassword123'
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Password should match with Password Confirmation')
      end
    end

    context 'when new password and password confirmation are match' do
      it 'returns an error message for password confirmation' do
        account.reload
        post :update_password, params: {
          token: token,
          current_password: account.password,
          new_password: 'Test@1234',
          password_confirmation: 'Test@1234'
        }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Password changed successfully')
      end
    end

    context 'when current password is incorrect' do
      it 'returns an unauthorized error message' do
        post :update_password, params: {
          token: token,
          current_password: 'incorrectpassword',
          new_password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        body = JSON.parse(response.body)
        expect(response).to have_http_status(:unauthorized)
        expect(body['error']).to eq('incorrect password')
      end
    end

    context 'when account update fails due to validation errors' do
      it 'returns validation error messages' do
        allow(account).to receive(:update).and_return(false)
        allow(account).to receive_message_chain(:errors, :full_messages).and_return(['Password is too short'])

        post :update_password, params: {
          token: token,
          current_password: account.password,
          new_password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'][0]).to eq("Password must include uppercase, lowercase, number, and special character")
      end
    end

    context 'when new password or password confirmation is missing' do
      it 'returns an error message' do
        post :update_password, params: {
         token: token,
          current_password: account.password,
          new_password: nil,
          password_confirmation: nil
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('New password and password confirmation are required')
      end
    end
  end
end
