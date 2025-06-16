require 'rails_helper'

RSpec.describe BxBlockProfile::UserProfilesController, type: :request do
  PASSWORD = "Password@123".freeze

  let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
  let!(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }
  let!(:artist_profile) { BxBlockProfile::ArtistProfile.create!(account_id: account.id) }


  describe 'User Profile management' do
   
    let(:valid_params) do
      {
        first_name: "John",
        last_name: "Doe",
        description: "Experienced artist",
        height: 180,
        weight: 75,
        location: "New York",
        gender: "Male",
        role: "Painter",
        experience_level: "Expert",
        portfolio_links: ["https://portfolio.com/johndoe"],
        social_media_links: ["https://twitter.com/johndoe"],
        languages: ["English", "Spanish"]
      }
    end

    let(:invalid_params) do
      {
        first_name: "",
        last_name: "Doe",
        description: "",
        height: nil,
        weight: nil,
        location: "",
        gender: "Male",
        role: "",
        experience_level: ""
      }
    end

    describe 'POST /user_profiles' do
      context 'with valid parameters' do
        it 'creates a new user profile' do
          post '/bx_block_profile/user_profiles', params: valid_params, headers: { 'token' => token }
          expect(response).to have_http_status(:created)
          expect(response.body).to include('Experienced artist')
        end
      end
    end

    describe 'PUT /user_profiles/:id' do
      let!(:user_profile) { FactoryBot.create(:artist_profile, account: account) }

      context 'when the record exists' do
        it 'updates the user profile' do
          put "/bx_block_profile/user_profiles/#{user_profile.id}", params: { first_name: "Updated Name" }, headers: { 'token' => token }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Artist Profile updated successfully')
        end
      end

      context 'when the record does not exist' do
        it 'returns not found' do
          put "/bx_block_profile/user_profiles/999999", params: { first_name: "Updated Name" }, headers: { 'token' => token }
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include('Artist Profile not found')
        end
      end
    end
  end

  describe 'GET /user_profiles' do

    context 'user profile' do
      it 'when search query is too short' do
        get "/bx_block_profile/user_profiles", params: { name: "a" }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("Please enter at least 3 characters for search")
      end

      it 'get all user profile' do
        get "/bx_block_profile/user_profiles"
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).not_to be_empty
        expect(json_response['data']).to be_an(Array)
      end

      it 'desc sorting profile' do
        get "/bx_block_profile/user_profiles", params: { sort_by: "name(Z-A)" }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_an(Array)
      end

      it 'sorrting asec user profile' do
        get "/bx_block_profile/user_profiles", params: { sort_by: "name(A-Z)" }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_an(Array)
      end

      it 'sorrting experience(Beginner-Expert)' do
        get "/bx_block_profile/user_profiles", params: { sort_by: "experience(Beginner-Expert)" }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_an(Array)
      end

      it 'sorrting experience(Beginner-Expert)' do
        get "/bx_block_profile/user_profiles", params: { sort_by: "experience(Expert-Beginner)" }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_an(Array)
      end

      it 'not found user profile' do
        BxBlockProfile::ArtistProfile.destroy_all
        get "/bx_block_profile/user_profiles"
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to eq("profiles does not exist")
      end
    end
  end
end
