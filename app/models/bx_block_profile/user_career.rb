module BxBlockProfile
	class UserCareer < ApplicationRecord
	  has_one_attached :career_image
	  self.table_name = :user_careers
  
	  belongs_to :account, class_name: "AccountBlock::Account"
  
	  validates :project_name, presence: true, length: { maximum: 250 }
	  validates :role, presence: true, length: { maximum: 250 }
	  validates :description, length: { maximum: 1000 }
	  validates :start_date, presence: true

	  validates :start_date, presence: true, format: { with: /\A[a-zA-Z\s]+\z/, message: "should contain only alphabets, only month name are allowed" }
	  validates :start_year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: Date.current.year }
	  validate :validate_end_fields_based_on_ongoing

  
	  validate :end_year_after_start_year
	  validate :validate_career_image_attachment

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
		    elsif !end_date.match(/\A[a-zA-Z\s]+\z/)
		      errors.add(:end_date, "should contain only alphabets, only month name are allowed")
		    end

		    if end_year.blank?
		      errors.add(:end_year, "can't be blank")
		    elsif end_year.to_i < 1900
		      errors.add(:end_year, "must be after 1900")
		    end
		  end
		end
  
	  def end_year_after_start_year
		if start_year.present? && end_year.present? && end_year < start_year
		  errors.add(:end_year, "cannot be less than the start year")
		end
	  end
  
	  def validate_career_image_attachment
		return unless career_image.attached?
  
		max_size = 10.megabytes # 10MB limit
		if career_image.blob.byte_size > max_size
		  errors.add(:career_image, "Max file size allowed is 10MB")
		end
  
		allowed_content_types = [
		  'image/png', 'image/jpeg', 'image/jpg', 'image/gif',
		  'application/pdf', 'application/msword',
		  'application/vnd.openxmlformats-officedocument.wordprocessingml.document' # .docx
		]
  
		unless allowed_content_types.include?(career_image.blob.content_type)
		  errors.add(:career_image, "Only images (PNG, JPEG, GIF, JPG) and documents (PDF, DOC, DOCX) are allowed")
		end
	  end
	end
  end
  