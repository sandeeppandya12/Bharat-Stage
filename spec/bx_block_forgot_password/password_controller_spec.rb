RSpec.describe BxBlockForgotPassword::PasswordsController, type: :request do
  describe 'Password reset functionality' do
    let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", full_phone_number: "+91#{rand(10**9..10**10 - 1)}", activated: true) }

    before do
      account.generate_password_reset_token!
      account.reload
    end

    let(:valid_reset_params) do
      { email: account.email }
    end

    let(:invalid_reset_params) do
      { email: 'nonexistent@example.com' }
    end

    let(:valid_change_params) do
      {
        reset_token: account.reset_password_token,
        password: 'Newpassword@123',
        password_confirmation: 'Newpassword@123'
      }
    end

    let(:invalid_change_params) do
      {
        reset_token: account.reset_password_token,
        password: 'newpassword123',
        password_confirmation: 'differentpassword123'
      }
    end

    let(:expired_reset_token_params) do
      {
        reset_token: 'expired_token',
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
    end

    describe 'POST /bx_block_forgot_password/reset_password' do
      context 'with valid email' do
        it 'sends the password reset email successfully' do
          post '/bx_block_forgot_password/reset_password', params: valid_reset_params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Password reset email sent!')
        end
      end

      context 'with invalid email' do
        it 'returns an error when account is not found' do
          post '/bx_block_forgot_password/reset_password', params: invalid_reset_params
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include('Account Not Found!')
        end
      end
    end

    describe 'POST /bx_block_forgot_password/change_password' do
      context 'with valid reset token and matching passwords' do
        it 'changes the password successfully' do
          post '/bx_block_forgot_password/change_password', params: valid_change_params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Password has been successfully reset.')
        end
      end

      context 'with valid reset token but mismatched passwords' do
        it 'returns an error when passwords do not match' do
          post '/bx_block_forgot_password/change_password', params: invalid_change_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Passwords do not match.')
        end
      end

      context 'with invalid reset token' do
        it 'returns an error when reset token is invalid or expired' do
          post '/bx_block_forgot_password/change_password', params: expired_reset_token_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Invalid or expired token.')
        end
      end
    end
  end
end
