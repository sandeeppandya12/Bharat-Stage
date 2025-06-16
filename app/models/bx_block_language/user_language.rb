module BxBlockLanguage
	class UserLanguage < ApplicationRecord
	  self.table_name = :user_languages
  
	  before_validation :normalize_name
  
	  validates :name, uniqueness: { case_sensitive: false }
  
	  private
  
	  def normalize_name
		self.name = name.strip.gsub(/\s+/, ' ') if name.present?
	  end
	end
end
  