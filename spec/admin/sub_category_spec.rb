require 'rails_helper'

RSpec.describe 'Admin SubCategory Management', type: :feature do
  let!(:admin_user) { FactoryBot.create(:admin_user) }

  before do
    visit new_admin_user_session_path
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Login'
  end
  let!(:category_name) { "Internet name" }
  let!(:category) { BxBlockCategories::Category.create!(name: category_name) }
  let!(:subcategory) { BxBlockCategories::SubCategory.create!(name: 'subcategory',  category_id: category.id) }

  describe 'Index Page' do
    it 'displays the subcategory list' do
      visit admin_sub_categories_path
      expect(page).to have_content(category_name)
    end
  end

  describe 'Show Page' do
    it 'displays subcategory details' do
      puts "Subcategory ID: #{subcategory.id}"
      visit admin_sub_category_path(subcategory)
  
      expect(page).to have_content(subcategory.name)
    end
  end
end
