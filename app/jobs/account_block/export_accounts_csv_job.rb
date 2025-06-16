require 'csv'

module AccountBlock
  class ExportAccountsCsvJob < ApplicationJob
    queue_as :default

    def perform
      file_path = Rails.root.join('tmp', "accounts_export_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv")

      CSV.open(file_path, 'w') do |csv|
        csv << ['Id', 'First Name', 'Last Name', 'Mobile Number', 'Email', 'Activated', 'Created At', 'Updated At', 'Roles', 'Blocked']

        AccountBlock::Account.find_each do |account|
          csv << [
            account.id,
            account.first_name,
            account.last_name,
            account.full_phone_number,
            account.email,
            account.activated,
            account.created_at.strftime("%d-%m-%Y %I:%M %p"),
            account.updated_at.strftime("%d-%m-%Y %I:%M %p"),
            account.roles,
            account.blocked
          ]
        end
      end

      file_path.to_s # Return the file path so it can be accessed in ActiveAdmin
    end
  end
end
