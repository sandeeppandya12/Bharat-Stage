module BxBlockDataImportExport
  class ExportController < ApplicationController
    require 'csv'

    def index
      if request.content_type == "text/csv"
        @csv_data = CSV.generate(headers: true) do |csv|
          fields = AccountBlock::Account.column_names.dup
          fields.delete('password_digest')
          fields.delete('unique_auth_id')
          csv << fields
          AccountBlock::Account.all.each do |account|
            csv << account.attributes.values_at(*fields)
          end
        end
        send_data @csv_data , :type => 'text/csv; charset=iso-8859-1; header=present',
                  :disposition => "attachment; filename=#{DateTime.now}.csv"
      else
        accounts = AccountBlock::Account.all
        render json: AccountSerializer.new(accounts, meta: {message: 'List of users.'
        }).serializable_hash, status: :ok
      end
    end
  end
end
