module BxBlockBaselinereporting
  module PatchEmergencyAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :account, class_name: 'AccountBlock::Account', foreign_key: :account_id

      scope :count_sos, ->(start_date, end_date) { where(created_at: start_date..end_date).count }
    end
  end
end
