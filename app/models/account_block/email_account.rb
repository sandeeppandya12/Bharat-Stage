module AccountBlock
  class EmailAccount < Account
    ActiveSupport.run_load_hooks(:email_account, self)
    include Wisper::Publisher
    validates :email, presence: true
    validates :full_phone_number, uniqueness: true, allow_blank: true
    validate :valid_phone_number

    def valid_phone_number
      if full_phone_number.present?
        unless Phonelib.valid?(full_phone_number)
          errors.add(:full_phone_number, "Invalid or Unrecognized Phone Number")
        end
      end
    end
  end
end
