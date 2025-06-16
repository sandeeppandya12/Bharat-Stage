module BxBlockTermsAndConditions
  class AboutUs < ApplicationRecord
    self.table_name = :about_us
    validates :description, presence: true
  end
end
