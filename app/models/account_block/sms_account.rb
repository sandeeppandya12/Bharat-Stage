module AccountBlock
  class SmsAccount < Account
    include Wisper::Publisher
    validates :full_phone_number, uniqueness: true, presence: true

    validate :valid_phone_number

    def valid_phone_number
      unless Phonelib.valid?(full_phone_number)
        errors.add(:full_phone_number, "Invalid or Unrecognized Phone Number")
      end
    end
  end
end                                                                                                                                                                                                                                