require 'rails_helper'

RSpec.describe BxBlockProfile::UserCareersController, type: :request do
  PASSWORD = "Password@123".freeze
  P_NAME = "Updated Project"
  
  describe 'User Career management' do
    let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
    let!(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }
    
    let(:valid_file) { fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg') }

    let(:invalid_file) { fixture_file_upload(Rails.root.join('spec/fixtures/first.mp4'), 'text/plain') }

    let(:valid_params) do
      {
        project_name: "Web Development",
        role: "Backend Developer",
        start_date: "Jnuary",
        end_date: "May",
        start_year: 2020,
        end_year: 2025,
        is_ongoing: false,
        location: "Remote",
        description: "Developed backend APIs",
        project_link: ["https://example.com"],
        career_image: valid_file
      }
    end
    
    let(:invalid_params) do
      {
        project_name: "",
        role: "Backend Developer",
        start_date: "2023-01-01",
        end_date: "2024-01-01",
        is_ongoing: false,
        location: "Remote",
        description: "Developed backend APIs",
        career_image: invalid_file
      }
    end

    context 'when is_ongoing is true and end fields are provided' do
      it 'returns validation errors for end_date and end_year' do
        params = valid_params.merge(is_ongoing: true, end_date: "May", end_year: 2025)
        
        post '/bx_block_profile/user_careers', params: params, headers: { 'token' => token }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("should not be present if career is ongoing")
      end
    end

    context 'when is_ongoing is true and end fields are omitted' do
      it 'creates a user career successfully' do
        params = valid_params.except(:end_date, :end_year).merge(is_ongoing: true)
        
        post '/bx_block_profile/user_careers', params: params, headers: { 'token' => token }

        expect(response).to have_http_status(:created)
        expect(response.body).to include("Web Development")
      end
    end

    context 'when is_ongoing is false and end fields are missing' do
      it 'returns validation errors for missing end_date and end_year' do
        params = valid_params.merge(end_date: nil, end_year: nil, is_ongoing: false)
        
        post '/bx_block_profile/user_careers', params: params, headers: { 'token' => token }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("End date can't be blank").and include("End year can't be blank")
      end
    end

    context 'when end_date is not in valid format' do
      it 'returns format validation error' do
        params = valid_params.merge(end_date: "05", is_ongoing: false)
        
        post '/bx_block_profile/user_careers', params: params, headers: { 'token' => token }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("should contain only alphabets, only month name are allowed")
      end
    end


    describe 'POST /user_careers' do
      context 'with valid parameters' do
        it 'creates a new user career' do
          post '/bx_block_profile/user_careers', params: valid_params, headers: { 'token' => token }
          expect(response).to have_http_status(:created)
          expect(response.body).to include('Web Development')
        end
      end

      context 'with invalid parameters' do
        it 'returns validation error for empty project name' do
          post '/bx_block_profile/user_careers', params: invalid_params, headers: { 'token' => token }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("Career image Only images (PNG, JPEG, GIF, JPG) and documents (PDF, DOC, DOCX) are allowed")
        end

        it 'returns validation error for unsupported file type' do
          post '/bx_block_profile/user_careers', params: invalid_params, headers: { 'token' => token }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Only images (PNG, JPEG, GIF, JPG) and documents (PDF, DOC, DOCX) are allowed')
        end
      end
    end
    
    describe 'PATCH /user_careers/:id' do
      let!(:user_career) { FactoryBot.create(:user_career, account: account, project_name: 'test project', role: 'actor', start_date: 'February', end_date: 'June', start_year: 2022, end_year: 2026) }
      
      context 'when the record exists' do
        it 'updates the user career' do
          patch "/bx_block_profile/user_careers/#{user_career.id}", params: { project_name: P_NAME }, headers: { 'token' => token }
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['data']['attributes']['project_name']).to eq(P_NAME)
        end
      end
      
      context 'when the record does not exist' do
        it 'returns not found' do
          patch "/bx_block_profile/user_careers/999999", params: { project_name: P_NAME }, headers: { 'token' => token }
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include('User Career not found')
        end
      end
    end
    
    describe 'DELETE /user_careers/:id' do
      let!(:user_career) { FactoryBot.create(:user_career, account: account, project_name: 'test project', role: 'actor', start_date: 'February', end_date: 'June', start_year: 2022, end_year: 2026) }

      context 'when the record exists' do
        it 'deletes the user career' do
          delete "/bx_block_profile/user_careers/#{user_career.id}", headers: { 'token' => token }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('User Career deleted successfully.')
        end
      end
      
      context 'when the record does not exist' do
        it 'returns not found' do
          delete "/bx_block_profile/user_careers/0", headers: { 'token' => token }
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include('User Career not found')
        end
      end
    end
  end
end
