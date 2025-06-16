class AddPasswordResetToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :reset_password_token, :string
    add_column :accounts, :reset_password_sent_at, :datetime
    add_column :accounts, :reset_token_expires_at, :datetime
  end
end
