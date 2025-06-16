require 'rails_helper'

RSpec.describe BxBlockProfile::UserEducationsController, type: :request do
  PASSWORD = "Password@123".freeze
  UNI_NAME = "ABC University"
  CREATE_ROUTE = '/bx_block_profile/user_educations'
  
  describe 'User Education management' do
    let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
    let!(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }
    
    let(:valid_params) do
      {
        institute_name: "XYZ University",
        qualification: "Bachelors in Computer Science",
        start_date: "January",
        end_date: "May",
        is_ongoing: false,
        location: "New York",
        start_year: 2022,
        end_year: 2025
      }
    end
    
    let(:invalid_params) do
      {
        institute_name: "YZ University",
        qualification: "Bachelr's in Computer Science",
        start_date: "Januay",
        end_date: "Ma",
        is_ongoing: false,
        location: "New York",
        start_year: 2020
      }
    end

    describe 'POST /user_educations' do
      context 'with valid parameters' do
        it 'creates a new user education' do
          post CREATE_ROUTE, params: valid_params, headers: { 'token' => token }
          expect(response).to have_http_status(:created)
          expect(response.body).to include("XYZ University")
        end
      end

      context 'with invalid parameters' do
        it 'gives a end date error for education is ongoing' do
          post CREATE_ROUTE, params: valid_params.merge(is_ongoing: true), headers: { 'token' => token }
          expect(JSON.parse(response.body)['errors'][0]).to eq("End date should not be present if career is ongoing")
          expect(JSON.parse(response.body)['errors'][1]).to eq("End year should not be present if career is ongoing")
        end
      end

      context 'with invalid end_date' do
        it 'gives a end date error mesage' do
          post CREATE_ROUTE, params: valid_params.merge(end_date: nil), headers: { 'token' => token }
          expect(JSON.parse(response.body)['errors'][0]).to eq("End date can't be blank")
        end
      end

      context 'with invalid end_year' do
        it 'gives a end year error message' do
          post CREATE_ROUTE, params: valid_params.merge(end_year: 1800 ), headers: { 'token' => token }
          expect(JSON.parse(response.body)['errors'][0]).to eq("End year cannot be less than the start year")
          expect(JSON.parse(response.body)['errors'][1]).to eq("End year must be after 1900")
        end
      end
    end
    
    describe 'PATCH /user_educations/:id' do
      let!(:user_education) { FactoryBot.create(:user_education, account: account, institute_name: 'madras univercity', qualification: 'B A', location: 'dallas', start_date: 'January', end_date: 'May', start_year: 2020, end_year: 2027) }
      
      context 'when the record exists' do
        it 'updates the user education' do
          patch "/bx_block_profile/user_educations/#{user_education.id}", params: { institute_name: UNI_NAME }, headers: { 'token' => token }
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['data']['attributes']['institute_name']).to eq(UNI_NAME)
        end
      end
      
      context 'when the record does not exist' do
        it 'returns not found' do
          patch "/bx_block_profile/user_educations/999999", params: { institute_name: UNI_NAME }, headers: { 'token' => token }
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)['error']).to eq('User Education not found')
        end
      end
    end
    
    describe 'DELETE /user_educations/:id' do
      let!(:user_education) { FactoryBot.create(:user_education, account: account, institute_name: 'madras univercity', qualification: 'B A', location: 'dallas', start_date: 'January', end_date: 'May', start_year: 2020, end_year: 2027) }
      context 'when the record exists' do
        it 'deletes the user education' do
          delete "/bx_block_profile/user_educations/#{user_education.id}", headers: { 'token' => token }
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['message']).to eq('Education deleted successfully.')
        end
      end
    end
  end
end
