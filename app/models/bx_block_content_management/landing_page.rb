module BxBlockContentManagement
  class LandingPage < BxBlockContentManagement::ApplicationRecord
     include RansackAllowlist
    self.table_name = :landing_pages

    validates :title, :description, presence: true

    has_one_attached :image

    validate :validate_image_format
    validate :validate_maximum_records, on: :create
    validate :validate_image_size

     def self.ransackable_associations(auth_object = nil)
    ["image_attachment", "image_blob"]
  end

 def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "id", "title", "updated_at"]
  end

    
    private
  
    def validate_image_format
      return unless image.attached?
      
      unless image.content_type.in?(%w[image/jpeg image/png image/jpg])
        errors.add(:image, 'must be a valid image format (JPG, JPEG, PNG)')
      end
    end

     def validate_maximum_records
      if LandingPage.count >= 3
        errors.add(:base, 'You can only create up to 3 landing pages.')
      end
    end

    def validate_image_size
      return unless image.attached?

      if image.blob.byte_size >= 10.megabytes
        errors.add(:image, 'File size should not exceed 10 mb')
      end
    end
  end 
end