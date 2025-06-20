module BxBlockOrderManagement
  class SubScriptionOrder < BxBlockOrderManagement::ApplicationRecord
    include RansackAllowlist
    self.table_name = :sub_scription_orders

    belongs_to :subscription, class_name: "BxBlockCustomUserSubs::Subscription"
    belongs_to :account, class_name: "AccountBlock::Account"
    default_scope { order(created_at: :desc) }
  end 
end