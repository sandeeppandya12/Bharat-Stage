FactoryBot.define do
  factory :subscription, class: 'BxBlockCustomUserSubs::Subscription' do
    name { "Free" }
    price { 100 }
  end
end
