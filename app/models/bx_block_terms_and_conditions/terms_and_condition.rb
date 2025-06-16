module BxBlockTermsAndConditions
  class TermsAndCondition < ApplicationRecord
# Protected Area Start
    has_many :user_terms_and_conditions,
      class_name: "BxBlockTermsAndConditions::UserTermAndCondition",
      dependent: :destroy, foreign_key: :terms_and_condition_id

# Protected Area End
    validates :description, presence: true
    validate :single_record_allowed, on: :create

    def get_accepted_accounts
      BxBlockTermsAndConditions::UserTermAndCondition
        .joins(:account)
        .select("accounts.*,bx_block_terms_and_conditions_user_term_and_conditions.*")
        .where(terms_and_condition_id: id, is_accepted: true)
    end
    
    private

    def single_record_allowed
      if BxBlockTermsAndConditions::TermsAndCondition.exists?
        errors.add(:base, "Only one Terms and Conditions is allowed.")
      end
    end

    class << self
      private

      def self.image_url(image)
        if image.attached?
          if Rails.env.development? || Rails.env.test?
            Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
          else
            image.service_url&.split("?")&.first
          end
        end
      end
    end
  end
end