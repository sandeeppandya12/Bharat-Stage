module BxBlockDataImportExport
  class AccountSerializer < BuilderBase::BaseSerializer
    attributes(:activated, :country_code, :email, :first_name, :full_phone_number, :last_name, :phone_number, :type, :created_at, :updated_at)
  end
end
