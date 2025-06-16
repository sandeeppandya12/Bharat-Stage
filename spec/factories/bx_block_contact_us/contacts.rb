FactoryBot.define do
    factory :contact, class: 'BxBlockContactUs::Contact' do
      email { Faker::Internet.email }
      full_phone_number { Faker::Number.number(digits: 10) }

    end
  end