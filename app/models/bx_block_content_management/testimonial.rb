module BxBlockContentManagement
  class Testimonial < BxBlockContentManagement::ApplicationRecord
    include RansackAllowlist
    self.table_name = :testimonials

    validates :profile_image, presence: true

    validates :name, presence: true, length: { maximum: 30 }
		validates :designation, presence: true, length: { maximum: 30 }
		validates :content, presence: true, length: { maximum: 300 }


    has_one_attached :profile_image

    validate :validate_image_format
    validate :validate_maximum_records, on: :create
    validate :validate_image_size
    
    private
  
    def validate_image_format
      return unless profile_image.attached?
      unless profile_image.content_type.in?(%w[image/jpeg image/png image/jpg])
        errors.add(:profile_image, 'must be a valid image format (JPG, JPEG, PNG)')
      end
    end

     def validate_maximum_records
      if Testimonial.count >= 5
        errors.add(:base, 'You can only create up to 5 Testimonial.')
      end
    end

    def validate_image_size
      return unless profile_image.attached?

      if profile_image.blob.byte_size >= 10.megabytes
        errors.add(:profile_image, 'File size should not exceed 10 mb')
      end
    end

   end
end

