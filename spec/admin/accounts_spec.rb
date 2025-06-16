require 'rails_helper'

RSpec.describe 'AccountBlock::Account Admin', type: :feature do
  let!(:account) do
    FactoryBot.create(:account,
                      email: "user_#{SecureRandom.hex(10)}@example.com",
                      password: "Password@123",
                      password_confirmation: "Password@123",
                      first_name: "John",
                      last_name: "Doe",
                      full_phone_number: "+91#{rand(10**9..10**10 - 1)}",
                      terms_accepted: true,
                      activated: true,
                      roles: 'Artist',
                      social_media_links: { 'facebook' => 'https://facebook.com/user', 'twitter' => 'https://twitter.com/user' },
                      portfolio_links: ['https://github.com/user', 'https://portfolio.com/user'],
                      languages: ['English', 'Hindi']
    )
  end

  let!(:user_links) { AccountBlock::UserLink.create(account_id: account.id, key: "portfolio link", value: "testme.com") }
  let!(:user_career) { FactoryBot.create(:user_career, account: account, project_name: 'test project', role: 'actor', start_date: 'February', end_date: 'June', start_year: 2022, end_year: 2026) }
  let!(:user_education) { FactoryBot.create(:user_education, account: account, institute_name: 'madras univercity', qualification: 'B A', location: 'dallas', start_date: 'January', end_date: 'May', start_year: 2020, end_year: 2027) }

  let(:admin_user) { FactoryBot.create(:admin_user) }
  let!(:category) { FactoryBot.create(:category, name: "Musicshudf") }
  let!(:sub_category) { FactoryBot.create(:sub_category, name: 'Singer', category: category) }

  let!(:account_sub_category_record) do
    AccountBlock::AccountsSubCategory.create(account: account, sub_category: sub_category)
  end

  before do
    visit new_admin_user_session_path
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Login'
  end

  describe 'Show Page' do
    it 'displays associated category and subcategory' do
      visit admin_account_block_account_path(account)

      within('div.panel', text: 'Professional Skills') do
        expect(page).to have_content("Category: #{category.name}")
        expect(page).to have_content(sub_category.name)
      end
    end

    it 'displays account details, user education, and user careers' do
      visit admin_account_block_account_path(account)

      expect(page).to have_content(account.first_name)
      expect(page).to have_content(account.last_name)
      expect(page).to have_content(account.email)
      expect(page).to have_content(account.roles)

      within('div.panel', text: 'User Educations') do
        expect(page).to have_content(user_education.institute_name)
        expect(page).to have_content(user_education.qualification)
        expect(page).to have_content(user_education.location)
      end

      within('div.panel', text: 'User Careers') do
        expect(page).to have_content(user_career.project_name)
        expect(page).to have_content(user_career.role)
        expect(page).to have_content(user_career.location)
      end
    end

    it 'displays "No education details available." if no user education records exist' do
      account.user_educations.destroy_all
      visit admin_account_block_account_path(account)

      within('div.panel', text: 'User Educations') do
        expect(page).to have_content('No education details available.')
      end
    end

    it 'displays portfolio links if available' do
      visit admin_account_block_account_path(account)
    
      within('div.panel', text: 'Portfolio Links') do
        if account.user_links.present?
          account.user_links.each do |link|
            expect(page).to have_link(link.value, href: link.value, target: '_blank')
          end
        else
          expect(page).to have_text('No Portfolio links available.')
        end
      end
    end

    it 'displays social media links if available' do
      visit admin_account_block_account_path(account)

      within('div.panel', text: 'Social Media Links') do
        account.social_media_links.each do |platform, link|
          expect(page).to have_link("#{platform.capitalize}: #{link}", href: link)
        end
      end
    end

    it 'displays "No career details available." if no user career records exist' do
      account.user_careers.destroy_all
      visit admin_account_block_account_path(account)
  
      within('div.panel', text: 'User Careers') do
        expect(page).to have_content('No career details available.')
      end
    end

    it 'displays languages if present' do
      account.update(languages: ['English', 'Hindi'])
      visit admin_account_block_account_path(account)

      within('div.panel', text: 'Languages') do
        expect(page).to have_content('English')
        expect(page).to have_content('Hindi')
      end
    end

    it 'displays "No languages added." if none are present' do
      account.update(languages: [])
      visit admin_account_block_account_path(account)

      within('div.panel', text: 'Languages') do
        expect(page).to have_content('No languages added.')
      end
    end
  end

  describe 'Edit Page' do
    it 'allows editing account details' do
      visit edit_admin_account_block_account_path(account)

      fill_in 'First name', with: 'UpdatedName'
      click_button 'Update Account'

      expect(page).to have_content('UpdatedName')
    end
  end

  describe 'Blocking and Unblocking Accounts' do
    it 'allows blocking and unblocking an account' do
      visit admin_account_block_accounts_path
      click_link 'Block', match: :first
    end
  end

  describe 'Filtering Accounts' do
    it 'filters accounts by first name' do
      visit admin_account_block_accounts_path
      fill_in 'First name', with: 'John'
      click_button 'Filter'

      expect(page).to have_content('John')
    end
  end

  describe 'Export CSV' do
    it 'exports accounts as CSV' do
      visit admin_account_block_accounts_path
      
      click_link 'Export Accounts to CSV'
      
      expect(page.response_headers['Content-Type']).to include('text/csv')
    end
  end
end
