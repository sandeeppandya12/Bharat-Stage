module BxBlockContentManagement
  class Subscribe < BxBlockContentManagement::ApplicationRecord
    self.table_name = :subscribes

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

   end
end