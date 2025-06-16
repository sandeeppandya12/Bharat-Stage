require 'rails_helper'

RSpec.describe BxBlockContentManagement::ContentManagementsController, type: :controller do

  describe 'GET #index' do
    context 'when content is present' do
      before do
        BxBlockContentManagement::ContentManagement.destroy_all
        BxBlockContentManagement::ContentManagement.create!(title: "Title 1", description: "Description 2")
      end 

    	it 'returns a list of all contents with status 200' do
        get :index
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].first['attributes']['title']).to eq("Title 1")
        expect(json_response['meta']['message']).to eq('List of all contents')
      end
    end

    context 'when no content is present' do
      before do
        BxBlockContentManagement::ContentManagement.destroy_all
      end   

      it 'returns a message with status 422' do
        get :index
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body) 
        expect(json_response['message']).to eq('No Content is present')
      end
    end
  end

  describe 'GET #index' do
    context 'when landing is present' do
      before do
        BxBlockContentManagement::LandingPage.create!(
          title: "abc", 
          description: "Description 2"
        )
      end   

      it 'returns a list of all contents' do
        get :landing_page
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].first['type']).to eq("landing_page")
      end
    end

    context 'no content is present' do
      it 'returns error message' do
        BxBlockContentManagement::LandingPage.destroy_all
        get :landing_page
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body) 
        expect(json_response['message']).to eq('No Content is present')
      end
    end
  end

  describe 'GET ' do
    context 'when  is present' do
      before do
        BxBlockContentManagement::Testimonial.destroy_all
        BxBlockContentManagement::Testimonial.create!(
          name: "abc", 
          content: "Description 2",
          designation: "Sample Content",
          profile_image: fixture_file_upload(Rails.root.join('spec/fixtures/girl.jpeg'), 'image/jpeg'),
        )
      end   

      it 'returns a list of all Testimonial' do
        get :testimonials
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].first['type']).to eq("testimonial")
      end
    end

    context 'no content' do
      it 'returns error message' do
        BxBlockContentManagement::Testimonial.destroy_all
        get :testimonials
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body) 
        expect(json_response['message']).to eq('No Content is present')
      end
    end
  end

  describe 'GET #index' do
    context 'when content is present' do
      it 'creates a new subscriber and returns status 201' do
        post :subscribe_email, params: { 
          subscribe: { email: "test@gmai.com" } 
        }

        expect(response).to have_http_status(:created) 

        json_response = JSON.parse(response.body)
        expect(json_response['data']['email']).to eq("test@gmai.com")  
        expect(json_response['message']).to eq('Subscribed successfully')
      end
    end

    context 'when no content is present' do
      it 'returns a message with status 422' do
        post :subscribe_email, params: { 
          subscribe: { email: "testgmai.com" } 
        }       
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body) 
        expect(json_response['error'].first).to eq("Email is invalid")
      end
    end
  end

end
