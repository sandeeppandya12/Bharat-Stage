class AddArtistProfileAttributesToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :description, :text
    add_column :accounts, :languages, :string, array: true, default: []
    add_column :accounts, :portfolio_links, :string, array: true, default: []
    add_column :accounts, :social_media_links, :string, array: true
    add_column :accounts, :height, :string
    add_column :accounts, :weight, :integer
    add_column :accounts, :location, :string
    add_column :accounts, :user_role, :string
    add_column :accounts, :experience_level, :string
    add_column :accounts, :blocked, :boolean, default: false
  end
end
