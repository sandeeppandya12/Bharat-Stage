class AddIsMobileVerifiedToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :is_mobile_verified, :boolean, default: false
  end
end
