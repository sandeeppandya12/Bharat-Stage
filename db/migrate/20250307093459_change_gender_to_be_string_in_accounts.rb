class ChangeGenderToBeStringInAccounts < ActiveRecord::Migration[6.1]
  def change
    change_column :accounts, :gender, :string
  end
end
