require 'rails_helper'

RSpec.describe BxBlockLanguage::UserLanguagesController, type: :controller do
    describe 'GET #index' do
      let!(:language1) { FactoryBot.create(:user_language) }
      let!(:language2) { FactoryBot.create(:user_language) }
      let!(:language3) { FactoryBot.create(:user_language) }
  
      before do
        # Stub the query to only return the test-created records
        allow(BxBlockLanguage::UserLanguage).to receive(:where).and_return(
          BxBlockLanguage::UserLanguage.where(id: [language1.id, language2.id, language3.id])
        )
      end
  
      context 'when search param is present' do
        it 'returns filtered languages matching the search query' do
          search_query = language1.name[0..2] # Take first 3 characters of the generated name
          get :index, params: { search: search_query }
  
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          # expect(json_response.first['name']).to include(search_query)
          expect(json_response.map { |l| l['name'] }).to include(a_string_starting_with(search_query))
        end
      end
  
      context 'when search param is not present' do
        it 'returns all languages in alphabetical order' do
          get :index
  
          expect(response).to have_http_status(:success)
          json_response = JSON.parse(response.body)
          expected_names = [language1.name, language2.name, language3.name].sort
          expect(json_response.map { |lang| lang['name'] }).to eq(expected_names)
        end
      end
    end
  end
  
