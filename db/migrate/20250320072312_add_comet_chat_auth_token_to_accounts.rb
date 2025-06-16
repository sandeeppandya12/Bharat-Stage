class AddCometChatAuthTokenToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :comet_chat_auth_token, :string
    add_column :accounts, :comet_chat_uid, :string
  end
end
