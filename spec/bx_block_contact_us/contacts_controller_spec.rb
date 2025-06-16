require 'rails_helper'

RSpec.describe BxBlockContactUs::ContactsController, type: :request do
  PASSWORD = "Password@123".freeze

  describe 'Contact management' do
    let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
    let!(:token) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') } # Generate a token

    let(:valid_file) { fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg') }
    let(:oversized_file) { fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg') } # Assuming you mock the large size in your validations
    let(:invalid_file) { fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg') } # This will be used in scenarios requiring type validation

    let(:valid_params) do
      {
        first_name: "John",
        last_name: "Doe",
        email: "newcontact@example.com",
        full_phone_number: '8888888888',
        subject: "Inquiry",
        message: "Need assistance.",
        contact_images: [valid_file]
      }
    end

    describe 'POST /contacts' do
      context 'with valid JPEG file' do
        it 'creates a new contact' do
          post '/bx_block_contact_us/contacts', params: valid_params, headers: { 'token' => token }
          expect(response).to have_http_status(:created)
          expect(response.body).to include('Need assistance.')
        end
      end
    end
  end
end
