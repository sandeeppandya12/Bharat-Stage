class AddVerificationTokenToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :verification_token, :string
  end
end
