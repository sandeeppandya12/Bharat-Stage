require 'rails_helper'

RSpec.describe BxBlockProfile::UserSkillsController, type: :request do
  PASSWORD = "Password@123".freeze

  describe 'User Skill management' do
    let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
    let!(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }

    let(:valid_params) do
      {
        experience_level: 'Intermediate'
      }
    end

    let!(:user_skill) { FactoryBot.create(:user_skill, account: account) }

    describe 'POST /user_skills' do
      context 'with valid parameters' do
        it 'creates a new user skill' do
          post '/bx_block_profile/user_skills', params: valid_params, headers: { 'token' => token }
          expect(response).to have_http_status(:created)
        end
      end
    end

    describe 'DELETE /user_skills/:id' do
      context 'when the record exists' do
        it 'deletes the user skill' do
          delete "/bx_block_profile/user_skills/#{user_skill.id}", headers: { 'token' => token }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Skill deleted successfully.')
        end
      end

      context 'when the record does not exist' do
        it 'returns not found' do
          delete "/bx_block_profile/user_skills/999999", headers: { 'token' => token }
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include('No Skill Found')
        end
      end
    end
  end
end
