FactoryBot.define do
    factory :user_skill, class: 'BxBlockProfile::UserSkill' do
      association :account, factory: :account
    end
  end
  