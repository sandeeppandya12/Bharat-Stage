module BxBlockProfile
	class UserEducation < ApplicationRecord
	  self.table_name = :user_educations
		ALPHA_SPACE_REGEX = /\A[a-zA-Z\s]+\z/
	  MESSAGE = "should contain only alphabets, only month name are allowed"
	  ALPHABET_MESSAGE = "should contain only alphabets"
  
	  belongs_to :account, class_name: "AccountBlock::Account"
  
		validates :institute_name, presence: true, length: { maximum: 250 }, format: { with: ALPHA_SPACE_REGEX, message: ALPHABET_MESSAGE }
		default_scope { order(created_at: :desc) }
		validates :qualification, presence: true, length: { maximum: 250 }, format: { with: ALPHA_SPACE_REGEX, message: ALPHABET_MESSAGE }
		validates :location, presence: true, length: { maximum: 250 }, format: { with: ALPHA_SPACE_REGEX, message: ALPHABET_MESSAGE }
		validates :start_date, presence: true, format: { with: ALPHA_SPACE_REGEX, message: MESSAGE }
		validates :start_year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: Date.current.year }

	  validate :end_year_after_start_year
	  validate :validate_end_fields_based_on_ongoing


	  def duration_in_words
	    start_month = Date.parse("01 #{start_date} #{start_year}") rescue nil
	    end_month = if is_ongoing
	                  Date.current
	                else
	                  Date.parse("01 #{end_date} #{end_year}") rescue nil
	                end

	    return "" if start_month.blank? || end_month.blank?

	    total_months = (end_month.year * 12 + end_month.month) - (start_month.year * 12 + start_month.month)
	    years = total_months / 12
	    months = total_months % 12

	    parts = []
	    parts << "#{years} #{'year'.pluralize(years)}" if years.positive?
	    parts << "#{months} #{'month'.pluralize(months)}" if months.positive?
	    parts.join(" ")
	  end
  
	  private
  
	  def end_year_after_start_year
			if start_year.present? && end_year.present? && end_year < start_year
				errors.add(:end_year, "cannot be less than the start year")
			end
	  end

	  def validate_end_fields_based_on_ongoing
		  if is_ongoing
		    if end_date.present?
		      errors.add(:end_date, "should not be present if career is ongoing")
		    end

		    if end_year.present?
		      errors.add(:end_year, "should not be present if career is ongoing")
		    end
		  else
		    if end_date.blank?
		      errors.add(:end_date, "can't be blank")
		    elsif !end_date.match(ALPHA_SPACE_REGEX)
		      errors.add(:end_date, MESSAGE)
		    end

		    if end_year.blank?
		      errors.add(:end_year, "can't be blank")
		    elsif end_year.to_i < 1900
		      errors.add(:end_year, "must be after 1900")
		    end
		  end
		end
	end
end
