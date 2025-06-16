FactoryBot.define do
    factory :admin_user do
      email { Faker::Internet.email }
      password { 'Password@123' }
      password_confirmation { 'Password@123' }
    end
  end
  