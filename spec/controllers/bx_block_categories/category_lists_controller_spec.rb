require 'rails_helper'

RSpec.describe BxBlockCategories::CategoryListsController, type: :controller do
  render_views

  let!(:category) { FactoryBot.create(:category, name: 'dance') }
  let!(:sub_category1) { FactoryBot.create(:sub_category, name: 'solo', category: category) }
  let!(:sub_category2) { FactoryBot.create(:sub_category, name: 'salsa', category: category) }

  describe 'GET #index' do
    context 'when category_name is provided' do
      it 'returns subcategories for the provided category name' do
        get :index, params: { category_name: 'dance' }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].first['attributes']['name']).to eq('solo')
        expect(json_response['data'].last['attributes']['name']).to eq('salsa')
      end

      it 'returns not found when no subcategories are present for the category' do
        get :index, params: { category_name: 'Invalid Category' }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('No subcategories found for this category name')
      end
    end

    context 'when category_name is NOT provided' do
      it 'returns a list of all categories with their subcategories' do
        get :index

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        category_names = json_response['data'].map { |category| category['attributes']['name'] }

        expect(category_names).to include(category.name)
      end
    end
  end
end
