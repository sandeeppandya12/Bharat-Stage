# This migration comes from bx_block_block_users (originally 20200921070223)
# Protected File
class CreateBxBlockBlockUsersBlockUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :block_users do |t|
      t.references :account, null: false, index: false
      t.bigint    :blocked_account, null: false, index: false
      t.timestamps
    end
  end
end
