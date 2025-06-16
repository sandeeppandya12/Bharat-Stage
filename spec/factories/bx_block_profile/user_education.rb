FactoryBot.define do
    factory :user_education, class: 'BxBlockProfile::UserEducation' do
      association :account, factory: :account
    end
end
  