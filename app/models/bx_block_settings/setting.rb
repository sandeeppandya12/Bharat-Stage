module BxBlockSettings
  class Setting < ApplicationRecord

    self.table_name = :settings
    belongs_to :account, class_name: "AccountBlock::Account"
    validates :two_factor_enabled, inclusion: { in: [true, false], message: "must be true or false" }
  end
end
