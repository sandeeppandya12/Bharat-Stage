FactoryBot.define do
    factory :user_language, class: 'BxBlockLanguage::UserLanguage' do
        name { Faker::Name.name }
    end
end