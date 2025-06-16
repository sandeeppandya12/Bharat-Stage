require 'rails_helper'

RSpec.describe AccountBlock::AccountsController, type: :request do
  PASSWORD = "Password@123".freeze
  FULL_PHONE_NUMBER = 9999929100.freeze
  ERROR_MESSAGE = 'returns an error message'.freeze
  ROUTES = '/account_block/accounts'.freeze
  ERROR = "Account not found"

  CATEGORY_NAME = Faker::Name.first_name
  SUB_CATEGORY_NAME = Faker::Name.first_name
  let!(:email_account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: FULL_PHONE_NUMBER, terms_accepted: true, activated: true) }
  let!(:token) { BuilderJsonWebToken.encode(email_account.id, 2.day.from_now, token_type: 'login') }
  let!(:token2) { BuilderJsonWebToken.encode(2, 2.day.from_now, token_type: 'login') }
  let!(:sms_otp) { AccountBlock::SmsOtp.create!(full_phone_number: '+919999929100', activated: true) }

  describe 'Account creation and management' do
    let(:valid_params) do
      {
        account: {
          first_name: "John",
          last_name: "Doe",
          email: "newuser@example.com",
          full_phone_number: FULL_PHONE_NUMBER,
          password: PASSWORD,
          password_confirmation: PASSWORD,
          terms_accepted: true
        }
      }
    end
    
    let(:invalid_email) do
      {
        account: {
          first_name: "Jane",
          last_name: "Doe",
          email: "john.doe@example.com", # Using already existing email
          full_phone_number: '8888888888',
          password: PASSWORD,
          password_confirmation: PASSWORD,
          terms_accepted: true
        }
      }
    end
    
    let(:invalid_email_format) do
      {
        account: {
          first_name: "Sam",
          last_name: "Smith",
          email: "invalidemail.@com", # Invalid email format
          full_phone_number: '7777777777',
          password: PASSWORD,
          password_confirmation: PASSWORD,
          terms_accepted: true
        }
      }
    end
    
    let(:invalid_password) do
      {
        account: {
          first_name: "Mike",
          last_name: "Johnson",
          email: "mike.johnson@example.com",
          full_phone_number: "9199929100",
          password: "short", # Invalid password
          password_confirmation: "short",
          terms_accepted: true
        }
      }
    end
    
    let(:valid_headers) do
      {
        'Authorization' => "Bearer #{BuilderJsonWebToken.encode(email_account.id)}"
      }
    end

    describe 'POST /account' do
      context 'with valid parameters' do

      before do
        allow(BxBlockCometchatintegration::CometChatService).to receive(:create_user).and_return({
          'data' => { 'uid' => 'test_uid' }
        })
        allow(BxBlockCometchatintegration::CometChatService).to receive(:generate_auth_token).and_return({
          'data' => { 'authToken' => 'auth_token_value', 'uid' => 'test_uid' }
        })
      end
        
      end

      context 'with valid parameters' do
        it 'creates a new account' do
          FactoryBot.create(:account, email: "newuser@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: 9988347602, terms_accepted: true, activated: true) 
          post ROUTES, params: valid_params, headers: valid_headers
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['errors'].first['email']).to eq("Oops! It looks like this email address is already in use. Please try logging in or use a different email to sign up.")
        end
      end

      context 'when phone number is already in use' do
        let!(:existing_account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: 9988347612, terms_accepted: true, activated: true) }
      
        it 'returns an error for duplicate phone number' do
          post ROUTES, params: {
            account: {
              first_name: "Duplicate",
              last_name: "User",
              email: "duplicate@example.com",
              full_phone_number: existing_account.full_phone_number, # Using the existing phone number
              password: PASSWORD,
              password_confirmation: PASSWORD,
              terms_accepted: true
            }
          }, headers: valid_headers
      
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['errors'].first['full_phone_number']).to eq("Oops! It looks like this phone_number address is already in use. Please try logging in or use a different phone number to sign up.")
        end
      end

      context 'with invalid password' do
        it "#{ERROR_MESSAGE} for invalid password" do
        AccountBlock::Account.destroy_all
          AccountBlock::SmsOtp.create!(full_phone_number: '+919199929100', activated: true) 
          post ROUTES, params: invalid_password, headers: valid_headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('Password is too short (minimum is 8 characters)')
        end
      end

    end

    describe 'PUT verify_account' do
      let!(:account) do
        FactoryBot.create(
          :account,
          verification_token: SecureRandom.hex(10), # Generate a random token
          email: "user_#{SecureRandom.hex(10)}@example.com",
          password: PASSWORD,
          password_confirmation: PASSWORD,
          full_phone_number: 9900990011,
          terms_accepted: true,
          activated: false
        )
      end
    
      context 'with valid token' do
        it 'verifies the account successfully' do
          put "/account_block/accounts/verify_account", params: { token: account.verification_token } 
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq("Account successfully verified!")
    
          account.reload
        end
      end
    end

    describe 'GET accounts' do
     let!(:category) { FactoryBot.create(:category) }
      let!(:sub_category1) { FactoryBot.create(:sub_category, category: category) }
      let!(:sub_category2) { FactoryBot.create(:sub_category, category: category) }

      let!(:email_account2) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", blocked: false, password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }

      before do
        AccountBlock::AccountsSubCategory.create(account: email_account, sub_category: sub_category1, experience_level: 0)
        AccountBlock::AccountsSubCategory.create(account: email_account2, sub_category: sub_category2, experience_level: 2)
      end

      it 'sorts accounts by experience level from Beginner to Expert' do
        get ROUTES, params: { sort_by: 'experience(Beginner-Expert)' }, headers: headers
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        sorted_experience_levels = json_response['accounts']['data'].map { |account| account['attributes']['sorted_experience_levels'] }
        expect(sorted_experience_levels).to eq(sorted_experience_levels.sort)
      end

      it 'sorts accounts by experience level from Expert to Beginner' do
        get ROUTES, params: { sort_by: 'experience(Expert-Beginner)' }, headers: headers
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        sorted_experience_levels = json_response['accounts']['data'].map { |account| account['attributes']['sorted_experience_levels'] }
        expect(sorted_experience_levels).to eq(sorted_experience_levels.sort.reverse)
      end
    end

    describe 'GET accounts' do
      context 'when accounts exist' do
        it 'returns all accounts' do
          get ROUTES, headers: valid_headers
          expect(response).to have_http_status(:ok)          
          json_response = JSON.parse(response.body)
          expect(json_response['accounts']['data'].first['type']).to eq('account')
        end
      end

      it 'desc sorting account' do
        get ROUTES, params: { sort_by: "name(Z-A)" }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['accounts']['data'].first['type']).to eq('account') 
      end

      it 'sorting asec user' do
        get ROUTES, params: { sort_by: "name(A-Z)" }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['accounts']['data'].first['type']).to eq('account')  
      end

      it 'sorted age range' do
        email_account.update(age:5,password:PASSWORD)
        get ROUTES, params:{ age_range: ['0-10', '20-30'] }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['accounts']['data'].count).to eq(1)  
      end

      it 'returns error when no accounts exist for the given age range' do
        email_account.update(age: 5, password: PASSWORD)

        get ROUTES, params: {
          language: ["d"] 
        }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response["error"]).to eq("accounts does not exist")
      end

      it 'filters by category and subcategory' do
        category = BxBlockCategories::Category.create!(name: "Travels")
        sub_category = BxBlockCategories::SubCategory.create!(name: "Char", category: category)
        account = AccountBlock::Account.create!(
          first_name: "a",
          last_name: "b",
          full_phone_number: '9999999009',
          terms_accepted: true,
          email: "test@example.com",
          password: PASSWORD,
          categories: [category],
          sub_categories: [sub_category]
        )
        account.save!

        sub_categories_param = { "Travels" => ["Char"] }.to_json
        get ROUTES, params: { sort_by: "name(A-Z)", skills: "Travels", sub_categories: sub_categories_param }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
      end

      it 'when search query is too short' do
        get ROUTES, params: { name: "a" }, headers: valid_headers
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("Please enter at least 3 characters for search")
      end

    end   
    
    let(:valid_update_params) do
    {
      account: {
        first_name: "UpdatedName",
        last_name: "UpdatedLastName",
        email: "updated.email@example.com",
        full_phone_number: '+918888888888',
      },
      categories: [
      {
        name: CATEGORY_NAME.downcase,
        sub_categories: [ { "name": SUB_CATEGORY_NAME.downcase, "experience_level": "intermediate" } ],
      }
    ]
    }
  end

  describe 'POST #resend_verification_email' do
   let!(:account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: 5500883322, terms_accepted: true, activated: false) }

  context 'when account does not exist' do
    it 'returns an error message' do
      post '/account_block/accounts/resend_verification_email', params: { email: 'nonexistent@example.com' }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq(
        'errors' => [{ 'email' => 'No account found with this email.' }]
      )
    end

    it 'returns an error message' do
      post '/account_block/accounts/resend_verification_email', params: { email: account.email }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq("A new verification email has been sent to #{account.email}.")
    end
  end  
end


  let(:invalid_update_params) do
     {
        account: {
          first_name: "", 
            last_name: "UpdatedLastName",
            email: "updated.email@example.com",
            full_phone_number: '8888888888'
        }
      }
  end

 describe 'PATCH /account_block/edit_profile_skill' do
    context 'when updating with valid parameters' do
      category = BxBlockCategories::Category.create!(name: CATEGORY_NAME.downcase)
        sub_category = BxBlockCategories::SubCategory.create!(name: SUB_CATEGORY_NAME.downcase, category: category)
      it 'updates account successfully' do
        put "/account_block/edit_profile_skill", params: valid_update_params, headers: {token: token}
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
        # expect(json_response['data']['attributes']['first_name']).to eq("UpdatedName")
      end
    end

    # let(:invalid_params) do
    #   {
    #     account: {
    #       first_name: "a12",
    #       last_name: "k12",
    #     }
    #   }
    # end
 
    # context 'when updating with invalid parameters' do
    #   it 'returns an error for invalid first name' do
    #     put "/account_block/edit_profile_skill", params: invalid_update_params, headers: {token: token}
    #     expect(response).to have_http_status(:unprocessable_entity)

    #     json_response = JSON.parse(response.body)
    #     expect(json_response['error']).to be_present
    #   end
    # end

    context 'when account does not exist' do
      it 'returns not found error' do
        invalid_token = BuilderJsonWebToken.encode(999999, 2.day.from_now, token_type: 'login') # Non-existing account
        put "/account_block/edit_profile_skill", params: valid_update_params, headers: {token: invalid_token}

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include(ERROR)
      end
    end
  end
    
    describe 'DELETE accounts :id' do
      context 'when account exists' do
        it 'deletes the account successfully' do
          delete "/account_block/accounts/#{email_account.id}", headers: valid_headers
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Account deleted successfully.')
        end
      end

      context 'when account does not exist' do
        it "#{ERROR_MESSAGE} when account is not found" do
          delete "/account_block/accounts/999999", headers: valid_headers # Non-existing ID
          expect(response).to have_http_status(:not_found)  # Expect 404 instead of 422
          expect(response.body).to include(ERROR)
        end
      end
    end
  end
   
  describe 'Edit user image' do
    context 'when image fails to attach' do
      it 'returns an error' do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')
        allow_any_instance_of(ActiveStorage::Attached::One).to receive(:attach).and_return(nil)
        put "/account_block/edit_profile_picture", params: { user_image: file }, headers: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Failed to upload file. Please try again.')
      end
    end

    it 'updates  user image successfully' do
      file = fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')
      email_account.update(user_image: file)
      put "/account_block/edit_profile_picture", params: { user_image: file }, headers: { token: token }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)   
      expect(json_response['data']).to be_present
      expect(json_response['data']['attributes']['user_image_url']).to be_present
    end

    context 'when uploading an invalid file type' do
      it 'returns an error' do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/beauty.svg'), 'image/svg')
        put "/account_block/edit_profile_picture", params: { user_image: file }, headers: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Maximum file size is 10MB and format should be JPG / JPEG / PNG.')
      end
    end

    context 'when uploading an invalid size ' do
      it "#{ERROR_MESSAGE}" do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/maximum.png'), 'image/png')
        put "/account_block/edit_profile_picture", params: { user_image: file }, headers: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Maximum file size is 10MB and format should be JPG / JPEG / PNG.')
      end
    end

    context 'invalid file type' do
      it "#{ERROR_MESSAGE}" do
        put "/account_block/edit_profile_picture", params: {  }, headers: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Image not attached.')
      end
    end
  end

  describe 'Edit edit_cover_photo' do
    context 'when image fails to attach' do
      it 'returns an error' do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')
        allow_any_instance_of(ActiveStorage::Attached::One).to receive(:attach).and_return(nil)
        put "/account_block/edit_cover_photo", params: { cover_photo: file }, headers: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Failed to upload file. Please try again.')
      end
    end

    it 'updates cover photo successfully' do
      file = fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')
      email_account.update(user_image: file)
      put "/account_block/edit_cover_photo", params: { cover_photo: file }, headers: { token: token }
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)   
      expect(json_response['data']).to be_present
      expect(json_response['data']['attributes']['cover_photo']).to be_present
    end

    context 'invalid file type' do
      it "#{ERROR_MESSAGE}" do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/beauty.svg'), 'image/svg')
        put "/account_block/edit_cover_photo", params: { cover_photo: file }, headers: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Maximum file size is 10MB and format should be JPG / JPEG / PNG.')
      end
    end

    context 'invalid file type' do
      it "#{ERROR_MESSAGE}" do
        put "/account_block/edit_cover_photo", params: {  }, headers: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Image not attached.')
      end
    end
  end

  describe 'DELETE /account_block/delete_sub_category' do
    let!(:category) { FactoryBot.create(:category) }
    let!(:sub_category) { FactoryBot.create(:sub_category, category: category) }

    before do
      AccountBlock::AccountsSubCategory.create(account: email_account, sub_category: sub_category, experience_level: 1)
      AccountBlock::AccountsSubCategory.create(account: email_account, sub_category: sub_category, experience_level: 1)
    end

    it 'deletes the subcategory successfully' do
      delete "/account_block/delete_sub_category",  params: { sub_category_id: sub_category.id }, headers: { token: token }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Subcategory deleted successfully.')
    end

    it 'returns an error when the subcategory is not found' do
      delete "/account_block/delete_sub_category", params: { sub_category_id: 9999 }, headers: { token: token }
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Subcategory not found')
    end
  end

  describe 'DELETE sub_category' do
    let!(:other_account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999900', terms_accepted: true, activated: true) }
    let!(:category) { FactoryBot.create(:category) }
    let!(:sub_category) { FactoryBot.create(:sub_category, category: category) }

    before do
      AccountBlock::AccountsSubCategory.create(account: other_account, sub_category: sub_category, experience_level: 1)
    end

    it 'returns an error when the subcategory does not belong to the user' do
      delete "/account_block/delete_sub_category", params: { sub_category_id: sub_category.id }, headers: { token: token }
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Subcategory does not belong to the user.')
    end
  end

  describe 'GET /show account' do
    it 'specific' do
      category = BxBlockCategories::Category.create!(name: "travells")
      sub_category = BxBlockCategories::SubCategory.create!(name: "shar", category: category)
      @account = AccountBlock::Account.create!(first_name:"a",last_name:"b",
        full_phone_number: '9999999009', terms_accepted: true, 
        email: "test@example.com",
        password: PASSWORD,
        categories: [category],
        sub_categories: [sub_category]
      )

       files = [
          fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'),
          fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')
        ]

      files.each do |file|
        @account.upload_media.attach(file)
      end
      @account.categories << category
      @account.sub_categories << sub_category
      @account.save!
      get "/account_block/accounts/#{@account.id}" 
      expect(response).to have_http_status(:ok)
      expect(@account.upload_media.attached?).to be_truthy
      json_response = JSON.parse(response.body)
      expect(json_response).to be_a(Hash)
    end

     it 'error' do
      get "/account_block/accounts/99999999" 
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include(ERROR)
    end


  end

  describe 'GET /india_states' do
    context 'when country is present' do
      it 'returns states in an array format' do
        get '/account_block/india_states' 

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include('Maharashtra')
        expect(json_response).to include('Uttar Pradesh')
        expect(json_response).to be_an_instance_of(Array)
      end
    end

    context 'when the country code is invalid' do
      it 'returns an error' do
        allow(ISO3166::Country).to receive(:new).with('IN').and_return(nil)

        get '/account_block/india_states'
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Country not found')
      end
    end
  end

  describe "GET #show_user_with_token" do
    context "when user exists" do
      it "returns the user details successfully" do
        category = BxBlockCategories::Category.create!(name: "travells")
        sub_category = BxBlockCategories::SubCategory.create!(name: "shar", category: category)
        account = AccountBlock::Account.create!(first_name:"a",last_name:"b",
          full_phone_number: '9999999009', terms_accepted: true, 
          email: "test@example.com",
          password: PASSWORD,
          categories: [category],
          sub_categories: [sub_category]
        )

        BxBlockProfile::UserCareer.create!(account_id: account.id, project_name: "Project A", role: "Backend Developer", start_date: "January", end_date: "May", start_year: 2019, end_year: 2026, is_ongoing: false,location: "New York", description: "Worked on backend API development.", project_link: ["https://github.com/example"])

        get "/account_block/show_user_with_token", params: { token: token }

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)

         expect(parsed_response).to be_a(Hash) 

        expect(parsed_response["data"]).not_to be_empty
        expect(parsed_response["data"]["attributes"]["email"]).to eq(email_account.email)
        expect(parsed_response["data"]["attributes"]["full_phone_number"]).to eq(email_account.full_phone_number)
        expect(parsed_response["data"]["attributes"]["activated"]).to be_truthy
        expect(parsed_response["data"]["attributes"]["full_name"]).to eq("#{email_account.first_name} #{email_account.last_name}".strip)
      end
    end

    context "when user does not exist" do
      it "returns an error message" do
        get "/account_block/show_user_with_token", params: { token: "invalid_token" }, as: :json
        expect(response).to have_http_status(:bad_request)

        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to have_key("errors")
        expect(parsed_response["errors"]).to be_an(Array)
        first_error = parsed_response["errors"].first
        expect(first_error["token"]).to eq("Invalid token")
      end
    end
  end

  describe 'PATCH' do
    let(:valid_update_params) do
      {
        account: {
          first_name: "UpdatedName",
          last_name: "UpdatedLastName",
          email: "updated.email@example.com",
          full_phone_number: '+918888888888',
        }
      }
    end
    context 'when updating with valid parameters' do
      it 'updates account successfully' do
        put "/account_block/edit_profile", params: valid_update_params, headers: {token: token}
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
        expect(json_response['data']['attributes']['first_name']).to eq("UpdatedName")
      end
    end

    let(:invalid_params) do
      {
        account: {
          first_name: "a12",
          last_name: "k12",
        }
      }
    end

    it 'returns an error for invalid first name' do
      put '/account_block/edit_profile', params: invalid_params, headers: { token: token }
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq(
        ["First name should contain only alphabets", "Last name should contain only alphabets"]
      )  
    end   
  end

end
