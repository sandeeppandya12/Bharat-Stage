class RemoveSocialMediaLinksFromAccounts < ActiveRecord::Migration[6.1]
  def change
    remove_column :accounts, :social_media_links, :string, array: true
  end
end
