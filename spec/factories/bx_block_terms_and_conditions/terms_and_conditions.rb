FactoryBot.define do
  factory :terms_and_conditions, class: 'BxBlockTermsAndConditions::TermsAndCondition' do
    title { "Test Title" }
    description { "Test Description" }
  end
end
