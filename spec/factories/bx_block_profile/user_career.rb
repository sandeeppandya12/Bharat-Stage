FactoryBot.define do
  factory :user_career, class: 'BxBlockProfile::UserCareer' do
    association :account, factory: :account
  end
end
