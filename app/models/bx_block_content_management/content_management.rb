module BxBlockContentManagement
  class ContentManagement < ApplicationRecord
    include RansackAllowlist
    self.table_name = :bx_block_content_management_content_managments
    has_many_attached :images
    has_one_attached :image
    enum user_type: { user_1: 1, user_2: 2 }
    scope :published, -> {where("publish_date < ?", DateTime.current)}

    validates :title, :description, presence: true
    validate :single_record_allowed, on: :create
    validate :validate_image_format
    validate :validate_image_size
    
    private
    
    def single_record_allowed
      if ContentManagement.exists?
        errors.add(:base, "Only one Content Management record is allowed.")
      end
    end

    def validate_image_format
      return unless image.attached?
      
      unless image.content_type.in?(%w[image/jpeg image/png image/jpg image/x-png])
        errors.add(:image, 'must be a valid image format (JPG, JPEG, PNG)')
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
