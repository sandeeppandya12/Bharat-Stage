# spec/factories/accounts.rb
FactoryBot.define do
    factory :account, class: 'AccountBlock::Account' do
      first_name { "John" }
      last_name { "Doe" }
      email { Faker::Internet.email }
      full_phone_number { '+919999929100' }
      password { "Password@123" }
      password_confirmation { "Password@123" }
      terms_accepted { true }
      roles { :Artist } 
      activated { true }

    end
  end
  