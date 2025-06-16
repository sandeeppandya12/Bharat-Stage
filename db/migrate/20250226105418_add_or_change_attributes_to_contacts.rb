class AddOrChangeAttributesToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :first_name, :string
    add_column :contacts, :last_name, :string
    add_column :contacts, :full_phone_number, :string
    add_column :contacts, :subject, :string
    add_column :contacts, :message, :text
    remove_column :contacts, :name, :string
    remove_column :contacts, :phone_number, :string
    remove_column :contacts, :description, :text
  end
end
