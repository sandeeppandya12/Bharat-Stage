class AddSocialMediaLinksToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :social_media_links, :jsonb, default: {}
  end
end
