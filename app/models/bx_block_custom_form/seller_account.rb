module BxBlockCustomForm
  class SellerAccount < BxBlockCustomForm::ApplicationRecord
    self.table_name = :seller_accounts
    acts_as_mappable :default_units => :kms,
                     :default_formula => :sphere,
                     :distance_field_name => :distance,
                     :lat_column_name => :lat,
                     :lng_column_name => :long

# Protected Area Start
    belongs_to :account, class_name: "AccountBlock::Account"
# Protected Area End
  end
end
