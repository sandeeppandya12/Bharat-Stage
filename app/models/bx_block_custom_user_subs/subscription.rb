module BxBlockCustomUserSubs
  class Subscription < ApplicationRecord
    include RansackAllowlist
    has_many :user_subscriptions,
             class_name: 'BxBlockCustomUserSubs::UserSubscription'
    has_many :accounts, through: :user_subscriptions, class_name: 'AccountBlock::Account'

    has_many :sub_scription_order, class_name: "BxBlockOrderManagement::SubScriptionOrder"
    has_many :accounts, through: :sub_scription_order 

    validates :name, presence: true
    validates :price, presence: true
    validates :razorpay_plan_id, uniqueness: true, allow_nil: true


    has_one_attached :image
    default_scope { order(id: :desc) }
  end
end
