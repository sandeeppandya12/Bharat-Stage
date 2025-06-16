class AddTwoFactorEnabledAndAccountAssociationToSettings < ActiveRecord::Migration[6.1]
  def change
    add_reference :settings, :account, foreign_key: true
    add_column :settings, :two_factor_enabled, :boolean, default: false, null: false
  end
end
