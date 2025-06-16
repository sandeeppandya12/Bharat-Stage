FactoryBot.define do
  factory :category, class: 'BxBlockCategories::Category' do
    name { Faker::Name.name }
  end
end
