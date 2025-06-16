require 'rails_helper'

RSpec.describe 'Admin Category Management', type: :feature do
  let!(:admin_user) { FactoryBot.create(:admin_user) }

  before do
    visit new_admin_user_session_path
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Login'
  end
  let!(:category_name) { "name" }
  let!(:category) { BxBlockCategories::Category.create(name: category_name) }

  describe 'Index Page' do
    it 'displays the category list' do
      visit admin_categories_path
      expect(page).to have_content(category_name)
    end
  end

  describe 'Creating a Category' do
    it 'allows admin to create a new category' do
      visit new_admin_category_path
      fill_in 'Name', with: 'New Category'
      click_button 'Create Category'
      expect(page).to have_content('Category was successfully created')
    end
  end

  describe 'Show Page' do
    it 'displays category details' do
      visit admin_category_path(category)
      expect(page).to have_content(category.name)
    end
  end
end
