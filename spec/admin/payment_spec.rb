require 'rails_helper'

RSpec.describe 'Admin Payments Page', type: :feature do
  let(:admin_user) { FactoryBot.create(:admin_user) }

  PASSWORD = "Password@123".freeze
  FULL_PHONE_NUMBER = '+919999929999'.freeze

  let!(:account) do
    FactoryBot.create(
      :account,
      razorpay_customer_id: 'cust_xyz789',
      email: 'test@example.com',
      first_name: 'Razor',
      last_name: 'User',
      password: PASSWORD,
      password_confirmation: PASSWORD,
      full_phone_number: FULL_PHONE_NUMBER,
      terms_accepted: true,
      activated: true
    )
  end

  before do
    allow_any_instance_of(BxBlockRazorpay::RazorpayIntegration).to receive(:fetch_subscription).and_return(
      OpenStruct.new(
        attributes: {
          "items" => [
            {
              'id' => 'sub_123456',
              'plan_id' => 'plan_QGTooO75vHdW6M',
              'customer_id' => 'cust_xyz789',
              'status' => 'active',
              'created_at' => Time.now.to_i,
              'paid_count' => 2,
              'remaining_count' => 1
            }
          ]
        }
      )
    )

    allow(Razorpay::Plan).to receive(:fetch).and_return(
      OpenStruct.new(
        attributes: {
          'item' => {
            'amount' => 9900,
            'name' => 'Monthly Plan'
          }
        }
      )
    )

    visit new_admin_user_session_path
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Login'
  end

  describe 'Index Page' do

    it 'displays completed or active Razorpay subscriptions' do
      visit admin_payments_path

      expect(page).to have_content('sub_123456')
      expect(page).to have_content('plan_QGTooO75vHdW6M')
      expect(page).to have_content('cust_xyz789')
      expect(page).to have_content('test@example.com')
      expect(page).to have_content('Razor')
      expect(page).to have_content('User')
      expect(page).to have_content('Active')
      expect(page).to have_link('View Subscription', href: 'https://dashboard.razorpay.com/app/subscriptions/sub_123456')
    end
  end

  describe 'Export CSV' do
    context 'when subscriptions exist' do
      it 'exports active/completed subscriptions to CSV' do
        visit admin_payments_path

        click_link 'Export Subscriptions to CSV'

        expect(page.response_headers['Content-Type']).to include('text/csv')
      end
    end

    context 'when no completed subscriptions are found' do

      before do
        allow_any_instance_of(BxBlockRazorpay::RazorpayIntegration).to receive(:fetch_subscription).and_return(
          OpenStruct.new(
            attributes: {
              "items" => [
                {
                  'id' => 'sub_000000',
                  'plan_id' => 'plan_dummy',
                  'customer_id' => 'cust_dummy',
                  'status' => 'cancelled',
                  'created_at' => Time.now.to_i,
                  'paid_count' => 0,
                  'remaining_count' => 0
                }
              ]
            }
          )
        )
      end

      it 'shows alert for no completed subscriptions' do

        visit admin_payments_path

        click_link 'Export Subscriptions to CSV'

        expect(page).to have_current_path(admin_payments_path)
        expect(page).to have_content('No completed subscriptions found to export.')
      end
    end

    context 'when no subscriptions are found' do
      before do
        allow_any_instance_of(BxBlockRazorpay::RazorpayIntegration).to receive(:fetch_subscription).and_return(
          OpenStruct.new(
            attributes: {
              "items" => []
            }
          )
        )
      end

      it 'shows alert for no subscriptions' do
        
        visit admin_payments_path

        click_link 'Export Subscriptions to CSV'

        expect(page).to have_current_path(admin_payments_path)
        expect(page).to have_content('No subscriptions found.')
      end
    end
  end
end
