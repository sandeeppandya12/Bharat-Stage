FactoryBot.define do
  factory :sub_scription_order, class: 'BxBlockOrderManagement::SubScriptionOrder' do
    account
    association :subscription, factory: :subscription
    gst { 10 }
    sub_total { 1000 }
    total { 1100 }
    order_date { Date.today }
    valid_date { Date.today + 2.days }
    status { "active" }
    order_number { SecureRandom.hex(6) }
    auto_renewal { true }
    active_plan { true }

    trait :expiring_today do
      valid_date { Date.today }
    end

    trait :expired_yesterday do
      valid_date { Date.today - 1.day }
      auto_renewal { false }
    end
  end
end