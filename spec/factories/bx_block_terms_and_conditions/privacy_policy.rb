FactoryBot.define do
  factory :privacy_policy, class: 'BxBlockTermsAndConditions::PrivacyPolicy' do
    title { "Test Privacy" }
    description { "Test Privacy Description" }
  end
end
