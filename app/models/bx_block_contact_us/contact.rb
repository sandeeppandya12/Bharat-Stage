module BxBlockContactUs
  class Contact < BxBlockContactUs::ApplicationRecord
    self.table_name = :contacts 
    has_many_attached :contact_images
    validates :first_name, presence: true, length: { maximum: 30 }, format: { with: /\A[a-zA-Z]+\z/, message: "should contain only alphabets" }
    validates :last_name, presence: true, length: { maximum: 30 }, format: { with: /\A[a-zA-Z]+\z/, message: "should contain only alphabets" }
    validates :email, presence: true, length: { maximum: 50 }, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\z/ }

    validates :full_phone_number, presence: true, 
                              numericality: { only_integer: true, message: "allows only digits" }, 
                              length: { is: 13, message: "must be exactly 10 digits" }, 
                              on: :create


    validates :subject, presence: true, length: { maximum: 50 }
    validates :message, presence: true, length: { maximum: 500 }
    before_validation :ensure_country_code, on: :create
    validate :validate_total_attachment_size
   

# Protected Area Start
    # belongs_to :account, class_name: "AccountBlock::Account"

# Protected Area End
    validate :valid_email, if: Proc.new { |c| c.email.present? }
    # validate :valid_phone_number, if: Proc.new { |c| c.full_phone_number.present? }

    def self.filter(query_params)
      ContactFilter.new(self, query_params).call
    end

    private



    def validate_total_attachment_size
      return unless contact_images.attached?
    
      total_size = contact_images.sum { |image| image.blob.byte_size }
      max_size = 10.megabytes # 10MB limit
    
      if total_size > max_size
        errors.add(:base, "Max file size allowed is 10MB")
      end
    
      allowed_content_types = [
        'image/png', 'image/jpeg', 'image/jpg', 'image/gif', 
        'application/pdf', 'application/msword', 
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document' # .docx
      ]
    
      contact_images.each do |image|
        unless allowed_content_types.include?(image.blob.content_type)
          errors.add(:base, "Only images (PNG, JPEG, GIF JPG) and documents (PDF, DOC, DOCX) are allowed")
        end
      end
    end


    def ensure_country_code
      return if full_phone_number.blank?
    
      full_phone_number.prepend('+91') unless full_phone_number.start_with?('+91')
    end

    def valid_email
      validator = AccountBlock::EmailValidation.new(email)
      errors.add(:email, "invalid") if !validator.valid?
    end
  end
end
