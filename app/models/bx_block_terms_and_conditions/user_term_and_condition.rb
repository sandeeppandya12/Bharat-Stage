module BxBlockTermsAndConditions
  class UserTermAndCondition < ApplicationRecord
    self.table_name = :bx_block_terms_and_conditions_user_term_and_conditions

# Protected Area Start
    belongs_to :account, class_name: "AccountBlock::Account"
    belongs_to :terms_and_condition, class_name: "BxBlockTermsAndConditions::TermsAndCondition"
# Protected Area End
  end
end
