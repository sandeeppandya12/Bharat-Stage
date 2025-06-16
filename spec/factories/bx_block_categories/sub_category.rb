FactoryBot.define do
  factory :sub_category, class: 'BxBlockCategories::SubCategory' do
    name { Faker::Name.name }
  end
end
