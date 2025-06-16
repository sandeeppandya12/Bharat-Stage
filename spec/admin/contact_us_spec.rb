require 'rails_helper'

RSpec.describe 'BxBlockContactUs::Contact Admin', type: :feature do
  let!(:contact) {
    FactoryBot.create(:contact,
      first_name: 'John',
      last_name: 'Doe',
      email: "user_#{SecureRandom.hex(10)}@example.com",
      full_phone_number: "+919876543210",
      subject: 'Inquiry',
      message: 'This is a test message'
    )
  }
  let(:admin_user) { FactoryBot.create(:admin_user) }

  before do
    visit new_admin_user_session_path
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Login'
  end

  describe 'Index Page' do
    it 'displays the list of contacts' do
      visit admin_contact_us_path
      
      expect(page).to have_content('Contacts')
      expect(page).to have_content(contact.first_name)
      expect(page).to have_content(contact.last_name)
      expect(page).to have_content(contact.email)
      expect(page).to have_content('Inquiry')
      expect(page).to have_content(contact.full_phone_number.to_s.sub(/\A\+?91/, ''))
    end

    it 'has the necessary columns' do
      visit admin_contact_us_path

      expect(page).to have_content('First name')
      expect(page).to have_content('Last name')
      expect(page).to have_content('Mobile Number')
      expect(page).to have_content('Email')
      expect(page).to have_content('Subject')
      expect(page).to have_content('Message')
      expect(page).to have_content('Created at')
    end
  end

  describe 'Show Page' do
    it 'displays contact details' do
      visit admin_contact_u_path(contact)
      
      expect(page).to have_content(contact.first_name)
      expect(page).to have_content(contact.last_name)
      expect(page).to have_content(contact.email)
      expect(page).to have_content(contact.subject)
      expect(page).to have_content(contact.message)
      expect(page).to have_content(contact.full_phone_number.to_s.sub(/\A\+?91/, ''))
      expect(page).to have_content(contact.created_at.in_time_zone("Asia/Kolkata").strftime("%d-%m-%Y %I:%M %p"))
    end
  end

  describe 'Edit Page' do
    it 'allows editing contact details' do
      visit edit_admin_contact_u_path(contact)

      fill_in 'First name', with: 'UpdatedFirstName'
      fill_in 'Last name', with: 'UpdatedLastName'
      fill_in 'Mobile Number', with: '9876543210'
      fill_in 'Email', with: 'updated@example.com'
      fill_in 'Subject', with: 'Updated Subject'
      fill_in 'Message', with: 'Updated Message'

      click_button 'Update Contact'

      expect(page).to have_content('Contact was successfully updated')
      expect(page).to have_content('UpdatedFirstName')
      expect(page).to have_content('UpdatedLastName')
      expect(page).to have_content('9876543210')
      expect(page).to have_content('updated@example.com')
      expect(page).to have_content('Updated Subject')
      expect(page).to have_content('Updated Message')
    end
  end

  describe 'Filtering' do
    it 'allows filtering by first name' do
      visit admin_contact_us_path
      fill_in 'First name', with: contact.first_name
      click_button 'Filter'

      expect(page).to have_content(contact.first_name)
    end

    it 'allows filtering by email' do
      visit admin_contact_us_path
      fill_in 'Email', with: contact.email
      click_button 'Filter'

      expect(page).to have_content(contact.email)
    end
  end
end
