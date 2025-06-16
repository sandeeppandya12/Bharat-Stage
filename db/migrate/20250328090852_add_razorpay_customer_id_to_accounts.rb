class AddRazorpayCustomerIdToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :razorpay_customer_id, :string
  end
end
