class AddIsEmailVerifyToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :is_email_verify, :boolean, default: false, null: false
  end
end
