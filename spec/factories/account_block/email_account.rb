FactoryBot.define do
  factory :email_account, class: 'AccountBlock::EmailAccount' do
    type { 'EmailAccount' }
    first_name { Faker::Name.first_name }
    last_name { "lastname" }
    email { Faker::Internet.email }
    password { 'Aamin@123' }
    terms_accepted { true }
    activated { true }
  end
end
