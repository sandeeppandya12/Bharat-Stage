require 'rails_helper'

RSpec.describe BxBlockTermsAndConditions::TermsAndCondition, type: :request do
    
  let!(:privacy_policy) { FactoryBot.create(:privacy_policy) }
    
  describe 'GET /privacy_policy' do
    context 'with valid parameters' do
      it 'returns privacy_policy' do
        get '/bx_block_terms_and_conditions/privacy_policy'
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['data'][0]['title']).to eq("Test Privacy")
      end
    end
  end
end
