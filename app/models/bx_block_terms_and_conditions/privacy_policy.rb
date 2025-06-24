module BxBlockTermsAndConditions
  class PrivacyPolicy < ApplicationRecord
    self.table_name = :privacy_policies
    validates :description, presence: true
    validate :single_record_allowed, on: :create

    private

    def single_record_allowed
      if BxBlockTermsAndConditions::PrivacyPolicy.exists?
        errors.add(:base, "Only one Privacy Policy is allowed.")
      end
    end
  end
end
