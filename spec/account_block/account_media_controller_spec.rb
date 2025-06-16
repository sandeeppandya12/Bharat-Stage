require 'rails_helper'

RSpec.describe AccountBlock::AccountMediaController, type: :request do
  PASSWORD = "Password@123".freeze
  let!(:email_account) { FactoryBot.create(:account, email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
  let!(:token) { BuilderJsonWebToken.encode(email_account.id, 2.day.from_now, token_type: 'login') }

  before do
    email_account.upload_media.attach(
      io: fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'),
      filename: 'girl.jpeg',
      content_type: 'image/jpeg'
    )
    email_account.save!(validate: false)
  end

  describe 'Patch /account_block/update_specific_media' do
    it 'successfully updates the media file' do
      new_file = fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')

      patch "/account_block/account_media/#{email_account.upload_media.first.id}/update_specific_media",
            params: { upload_media: new_file }, headers: { token: token }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      email_account.reload
      expect(email_account.upload_media.first.filename.to_s).to eq('girl.jpeg')
    end

     context 'when ActiveStorage::IntegrityError occurs' do
      it 'returns an error message with status 422' do
        new_file = fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')
        allow_any_instance_of(ActiveStorage::Attached::Many).to receive(:attach).and_raise(ActiveStorage::IntegrityError, "Invalid file data")

        patch "/account_block/account_media/#{email_account.upload_media.first.id}/update_specific_media",
              params: { upload_media: new_file },
              headers: { token: token }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('File upload failed due to integrity issues')
      end
    end

    context 'when account is found' do
      it 'returns an error when file is not provided' do
        media_id = email_account.upload_media.first.id
        patch "/account_block/account_media/#{media_id}/update_specific_media",
            params: {}, headers: { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('No file provided.')
      end

    end

    context 'when attachment is not found at specified index' do
      it 'returns an error' do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/first.mp4'), 'video/mp4')

        patch "/account_block/account_media/99999/update_specific_media",
          params: { upload_media: file},
          headers: { token: token }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('File not found.')
      end
    end
  end

  describe 'Edit Failed' do
    it 'returns an error when account is not found' do
	    invalid_token = BuilderJsonWebToken.encode(999, 2.day.from_now, token_type: 'login')
	    post "/account_block/upload_media", params: {}, headers: { token: invalid_token }
	    expect(response).to have_http_status(:not_found)
	    json_response = JSON.parse(response.body)
	    expect(json_response['error']).to eq('Account not found')
	  end

	  it 'returns an error when uploading more than 5 photos' do
	    files = Array.new(21) { fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg') }
	    post "/account_block/upload_media", params: { upload_media: files }, headers:  { token: token }
	    expect(response).to have_http_status(:unprocessable_entity)
	    json_response = JSON.parse(response.body)
	    expect(json_response['error']).to eq('Maximum 20 images are allowed.')
	  end

    it 'returns an error when uploading more than 5 photos' do
      files = Array.new(6) { fixture_file_upload(Rails.root.join('spec/fixtures/first.mp4'), 'video/mp4') }
      post "/account_block/upload_media", params: { upload_media: files }, headers:  { token: token }
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Maximum 5 videos are allowed.')
    end

    it 'returns an error when uploading more than 5 pdfs' do
      files = Array.new(6) { fixture_file_upload(Rails.root.join('spec/fixtures/dummy.pdf'), 'application/pdf') }
      post "/account_block/upload_media", params: { upload_media: files }, headers:  { token: token }
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Maximum 5 pdfs are allowed.')
    end

    it 'returns an error 5 audios' do
      files = Array.new(6) { fixture_file_upload(Rails.root.join('spec/fixtures/song.mp3'), 'audio/mpeg') }
      post "/account_block/upload_media", params: { upload_media: files }, headers:  { token: token }
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Maximum 5 audios are allowed.')
    end

    it 'returns an error for image exceeding size limit' do
	    file = fixture_file_upload(Rails.root.join('spec/fixtures/maximum.png'), 'image/png')
	    post "/account_block/upload_media", params: { upload_media: [file] }, headers: { token: token }
	    expect(response).to have_http_status(:unprocessable_entity)
	    json_response = JSON.parse(response.body)
	    expect(json_response['error']).to eq('The maximum file size for photos is 10MB and videos is 100MB.')
	  end

	  it 'returns an error message for unsupported file type' do
	    file = fixture_file_upload(Rails.root.join('spec/fixtures/k.webp'), 'image/webp')
	    post "/account_block/upload_media", params: { upload_media: [file] }, headers:  { token: token }
	    expect(response).to have_http_status(:unprocessable_entity)
	    json_response = JSON.parse(response.body)
	    expect(json_response['error']).to eq('Only support .JPEG, .JPG, .PNG, .SVG, .MP4, .AVI, .MP3 and PDF files.')
	  end

    it 'uploads multiple images and videos successfully' do
	    files = [
	      fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'),
	      fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg')
	    ]
	    post "/account_block/upload_media", params: { upload_media: files }, headers:  { token: token }
	    expect(response).to have_http_status(:ok)
	    json_response = JSON.parse(response.body)
	    expect(json_response['data']).to be_present
	  end

    it 'uploads multiple videos successfully' do
      files = [
        fixture_file_upload(Rails.root.join('spec/fixtures/first.mp4'), 'video/mp4'),
        fixture_file_upload(Rails.root.join('spec/fixtures/first.mp4'), 'video/mp4')
      ]
      post "/account_block/upload_media", params: { upload_media: files }, headers:  { token: token }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_present
    end
  end

  describe 'Portfolio Links' do
    context 'when account is not found' do
      it 'returns an error' do
        invalid_token = BuilderJsonWebToken.encode(999, 2.days.from_now, token_type: 'login')
        put "/account_block/portfolio_links", params: {}, headers: { token: invalid_token }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Account not found')
      end
    end

    context 'when valid portfolio links are provided' do
      it 'updates the portfolio links successfully' do
        params = {
          account: {
            user_links: {
              github: 'https://github.com/user',
              linkedin: 'https://linkedin.com/in/user',
              website: 'https://user.com'
            }
          }
        }

        put '/account_block/portfolio_links', params: params, headers: { token: token }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

       expect(json_response['data']['attributes']['user_links']['github']).to eq('https://github.com/user')
       expect(json_response['data']['attributes']['user_links']['linkedin']).to eq('https://linkedin.com/in/user')
      end
    end
  end

  describe 'PuT /account_block/social_media_links' do
    context 'when social media links are valid' do
      it 'updates social media links successfully' do
        params = {
          social_media_links: {
            facebook: 'https://facebook.com/user',
            instagram: 'https://instagram.com/user',
            X: 'https://twitter.com/user',
            youtube: 'https://youtube.com/user',
            linkedin: 'https://linkedin.com/in/user'
          }
        }

        put '/account_block/social_media_links', params: params, headers:  { token: token }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_present
        expect(json_response['data']['attributes']['social_media_links']['facebook']).to eq('https://facebook.com/user')
        expect(json_response['data']['attributes']['social_media_links']['instagram']).to eq('https://instagram.com/user')
        expect(json_response['data']['attributes']['social_media_links']['X']).to eq('https://twitter.com/user')
        expect(json_response['data']['attributes']['social_media_links']['youtube']).to eq('https://youtube.com/user')
        expect(json_response['data']['attributes']['social_media_links']['linkedin']).to eq('https://linkedin.com/in/user')
      end
    end
  end

  describe 'DELETE #delete_profile_image' do
    let!(:account) { FactoryBot.create(:account, user_image: fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'), cover_photo: fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'), email: "user_#{SecureRandom.hex(10)}@example.com", password: PASSWORD, password_confirmation: PASSWORD, full_phone_number: '+919999999999', terms_accepted: true, activated: true) }
    let!(:token2) { BuilderJsonWebToken.encode(account.id, 2.day.from_now, token_type: 'login') }

    context 'when profile image exists' do
     it 'deletes the profile image successfully' do
        delete '/account_block/delete_profile_image', headers:  { token: token2 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Profile picture deleted successfully.')
      end
    end

    context 'when profile image does not exist' do
      it ' error message' do
        delete '/account_block/delete_profile_image', headers:  { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('No profile picture found.')
      end
    end

    context 'when profile cove does not exist' do
      it 'returns an cover error message' do
        delete '/account_block/delete_cover_image', headers:  { token: token }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('No cover photo found.')
      end
    end

    context 'when cover image exists' do
     it 'deletes the cover image successfully' do
        delete '/account_block/delete_cover_image', headers:  { token: token2 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Cover photo deleted successfully.')
      end
    end

    it 'file error message' do
      delete '/account_block/account_media/99999/delete_specific_media', headers:  { token: token }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('File not found.')
    end

    it 'successfully message' do
      delete "/account_block/account_media/#{email_account.upload_media.first.id}/delete_specific_media", headers:  { token: token }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('File deleted successfully.')
    end
  end

end
