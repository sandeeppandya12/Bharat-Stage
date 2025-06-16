class AddRoleAndTermsAcceptedToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :terms_accepted, :boolean, default: false, null: false
  end
end
