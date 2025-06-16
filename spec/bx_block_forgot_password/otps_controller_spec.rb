require 'rails_helper'


RSpec.describe BxBlockForgotPassword::OtpsController, type: :request do
  describe 'OTP functionality' do
    let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", full_phone_number: '+919999999999', activated: true, is_mobile_verified: false) }

    let(:valid_send_params) { { full_phone_number: '+918305658951' } }
    let(:invalid_send_params) { { full_phone_number: 'invalidphone' } }
    let(:invalid_verify_params) { { phone_number: '918305658951', pin: '654321' } }
    let(:expired_otp_params) { { phone_number: '918305658951', pin: 123456 } }
    let!(:sms_otp) { AccountBlock::SmsOtp.create!(full_phone_number: '+919999999999', activated: true) }


    before do
      allow(AccountBlock::SmsOtp).to receive(:create!).and_return(instance_double(AccountBlock::SmsOtp, pin: 123456, valid_until: 1.hour.from_now))
      allow(AccountBlock::SmsOtp).to receive(:find_by).and_return(nil)

      twilio_mock = double("TwilioClient")
      messages_mock = double("Messages", create: double("Message", sid: "fake_sid"))
      allow(twilio_mock).to receive(:messages).and_return(messages_mock)
      allow(Twilio::REST::Client).to receive(:new).and_return(twilio_mock)
    end

    describe 'POST /bx_block_forgot_password/otps/send_verification_code' do
      context 'with valid phone number' do
        it 'sends the verification code successfully' do
          post '/bx_block_forgot_password/send_verification_code', params: valid_send_params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('A verification code has been sent to your mobile number.')
        end
      end

      context 'with invalid phone number format' do
        it 'returns an error for invalid phone number format' do
          post '/bx_block_forgot_password/send_verification_code', params: invalid_send_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Full phone number Invalid or Unrecognized Phone Number')
        end
      end
    end

    describe 'POST /bx_block_forgot_password/verify_otp' do
      context 'with valid OTP' do
        before do
          sms_otp_mock = instance_double(AccountBlock::SmsOtp, pin: 123456, valid_until: 1.hour.from_now)
          allow(sms_otp_mock).to receive(:update_column).with(:activated, true)
          allow(AccountBlock::SmsOtp).to receive(:find_by).and_return(sms_otp_mock)
          allow(AccountBlock::Account).to receive(:find_by).and_return(account)
        end

        it 'verifies the OTP successfully' do
          valid_verify_params = { pin: 1234, phone_number: '918305658951' }
          post '/bx_block_forgot_password/verify_otp', params: valid_verify_params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('OTP is valid.')
        end
      end

      context 'with no OTP found' do
        before do
          allow(AccountBlock::SmsOtp).to receive(:find_by).and_return(nil)
        end

        it 'returns an error when OTP is not found for the phone number' do
          post '/bx_block_forgot_password/verify_otp', params: { phone_number: '9999999999', pin: 123456 }
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include('No OTP found for this phone number.')
        end
      end
    end

    # New test cases for two_factor_otp_verify
    describe 'POST /bx_block_forgot_password/two_factor_otp_verify' do
      context 'when phone number is in 10-digit format' do
        it 'prepends +91 to the phone number and verifies OTP' do
          sms_otp_mock = instance_double(AccountBlock::SmsOtp, pin: 1234, valid_until: 1.hour.from_now)
          allow(AccountBlock::SmsOtp).to receive(:find_by).with(full_phone_number: '9199999999').and_return(sms_otp_mock)
          allow(AccountBlock::Account).to receive(:find_by).and_return(account)

          post '/bx_block_forgot_password/two_factor_otp_verify', params: { phone_number: '919999999999', pin: '1234' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('OTP is valid. Mobile number verified.')
        end
      end

      context 'when OTP is valid' do
        it 'marks the phone number as verified and returns a token' do
          sms_otp_mock = instance_double(AccountBlock::SmsOtp, pin: 123456, valid_until: 1.hour.from_now)
          allow(AccountBlock::SmsOtp).to receive(:find_by).with(full_phone_number: '+919999999999').and_return(sms_otp_mock)
          allow(AccountBlock::Account).to receive(:find_by).with(full_phone_number: '919999999999').and_return(account)

          post '/bx_block_forgot_password/two_factor_otp_verify', params: { phone_number: '9999999999', pin: '1234' }
          account.reload
          expect(response).to have_http_status(:ok)
          expect(account.is_mobile_verified).to be true
          expect(response.body).to include('OTP is valid. Mobile number verified.')
        end
      end

      context 'when OTP is invalid or expired' do
        it 'returns an error for invalid OTP' do
          sms_otp_mock = instance_double(AccountBlock::SmsOtp, pin: 123456, valid_until: 1.hour.ago)
          allow(AccountBlock::SmsOtp).to receive(:find_by).and_return(sms_otp_mock)

          post '/bx_block_forgot_password/two_factor_otp_verify', params: { phone_number: '9999999999', pin: '654321' }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Invalid or expired OTP.')
        end
      end

      context 'when no OTP is found for the phone number' do
        it 'returns a not found error' do
          allow(AccountBlock::SmsOtp).to receive(:find_by).and_return(nil)

          post '/bx_block_forgot_password/two_factor_otp_verify', params: { phone_number: '91999999999', pin: '1234' }
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include('No OTP found for this phone number.')
        end
      end
    end
  end
end
