class CreateSubScriptionOrder < ActiveRecord::Migration[6.1]
  def change
    create_table :sub_scription_orders do |t|
      t.integer :account_id
      t.integer :subscription_id
      t.integer :gst, default: "0"
      t.integer :sub_total, default: "0"
      t.integer :total, default: "0"
      t.datetime :order_date
      t.datetime :valid_date
      t.string :status
      t.string :order_number
      t.boolean :auto_renewal, default: 0

      t.timestamps
    end
  end
end
