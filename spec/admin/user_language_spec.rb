require 'rails_helper'

RSpec.describe 'BxBlockLanguage::Languages Admin', type: :feature do
  let!(:user_language) { FactoryBot.create(:user_language) }
  let(:admin_user) { FactoryBot.create(:admin_user) }

  before do
    visit new_admin_user_session_path
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Login'
  end

  describe 'Index Page' do
    it 'displays the list of user languages' do
      visit admin_languages_path

      expect(page).to have_text('Languages')
      expect(page).to have_text(user_language.id.to_s)
      expect(page).to have_text(user_language.name)
    end

    it 'has the necessary columns' do
      visit admin_languages_path

      expect(page).to have_text('Id')
      expect(page).to have_text('Name')
      expect(page).to have_text('Actions')
    end
  end

  describe 'Show Page' do
    it 'displays user language details' do
      visit admin_language_path(user_language)

      expect(page).to have_text(user_language.id.to_s)
      expect(page).to have_text(user_language.name)
    end
  end

  describe 'Create Page' do
    it 'allows creating a new user language' do
      visit new_admin_language_path

      fill_in 'Name', with: 'French'
      click_button 'Create User language'

      expect(page).to have_text('User language was successfully created')
    end
  end

  describe 'Edit Page' do
    it 'allows editing user language details' do
      visit edit_admin_language_path(user_language)

      fill_in 'Name', with: 'Spanish'
      click_button 'Update User language'

      expect(page).to have_text('User language was successfully updated')
    end
  end

  describe 'Filtering' do
    it 'allows filtering by name' do
      visit admin_languages_path
      fill_in 'Name', with: user_language.name
      click_button 'Filter'

      expect(page).to have_text(user_language.name)
    end
  end
end
