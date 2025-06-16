module AccountBlock
  class Account < AccountBlock::ApplicationRecord
    ActiveSupport.run_load_hooks(:account, self)
    self.table_name = :accounts

    has_many :notifications, class_name: "BxBlockNotifications::Notification", dependent: :destroy

    has_many :sub_scription_orders, class_name: "BxBlockOrderManagement::SubScriptionOrder"
    has_many :subscriptions, through: :sub_scription_orders  

    # has_and_belongs_to_many :categories, class_name: "BxBlockCategories::Category"
    has_and_belongs_to_many :categories, class_name: "BxBlockCategories::Category", join_table: :accounts_categories


    has_and_belongs_to_many :sub_categories, class_name: "BxBlockCategories::SubCategory", join_table: "accounts_sub_categories" do
      def with_experience_level
        select('sub_categories.*, accounts_sub_categories.experience_level as experience_level')
      end
    end

    has_many :user_careers, class_name: "BxBlockProfile::UserCareer", dependent: :destroy
    has_many :user_educations, class_name: "BxBlockProfile::UserEducation", dependent: :destroy
    has_one_attached :profile_picture 
    has_one_attached :cover_photo
    has_one_attached :user_image
    has_many_attached :upload_media
    attr_accessor :skip_phone_validation
      
    has_many :user_links, dependent: :destroy
    accepts_nested_attributes_for :user_links, allow_destroy: true
    validate :valid_social_media_links, on: :social_media_update

    validates :first_name, presence: true, length: { maximum: 30 }, format: { with: /\A[a-zA-Z]+\z/, message: "should contain only alphabets" }
    validates :last_name, presence: true, length: { maximum: 30 }, format: { with: /\A[a-zA-Z]+\z/, message: "should contain only alphabets" }
    validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\z/ }, allow_blank: true
    validates :full_phone_number, presence: true, uniqueness: true, numericality: { only_integer: true }, format: { with: /\A(\+91\d{10}|\d{10})\z/, message: "Mobile Number should be 10 digits" },unless: :skip_phone_validation?, on: :create
    validates :description, length: { maximum: 1000, message: 'Max Character limit 1000' }

    validates :password, length: { minimum: 8 }, format: { with: /\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/, message: "must include uppercase, lowercase, number, and special character" }, allow_blank: true
    validates :terms_accepted, acceptance: { message: "You must accept terms & conditions" }, on: :create
    enum roles: { Artist: "Artist", Film_Maker: "Film_Maker" }, _suffix: true
    include Wisper::Publisher
    enum gender: { male: "Male", female: "Female", others: "Others", other: "Other" }, _prefix: true
    has_secure_password
    after_validation :parse_full_phone_number

    before_create :generate_api_key
    has_one :blacklist_user, class_name: "AccountBlock::BlackListUser", dependent: :destroy
    after_save :set_black_listed_user
    before_create :generate_verification_token
    after_create :create_razorpay_customer

    enum status: %i[regular suspended deleted]

    scope :active, -> { where(activated: true) }
    scope :existing_accounts, -> { where(status: ["regular", "suspended"]) }
    scope :search_by_name, ->(name) {
      where(
        "LOWER(first_name) LIKE :name_start OR LOWER(last_name) LIKE :name_start OR LOWER(CONCAT(first_name, ' ', last_name)) LIKE :name_start",
        name_start: "#{name.downcase}%"
      )
    }

    has_one :setting, class_name: "BxBlockSettings::Setting", dependent: :destroy
    after_create :create_default_settings

    def generate_password_reset_token!
      self.reset_password_token = SecureRandom.urlsafe_base64
      self.reset_token_expires_at = 30.minutes.from_now
      save(validate: false)
    end

    def generate_verification_token
      self.verification_token = SecureRandom.hex(10)
    end

    def verify_account_email
      update_columns(activated: true, verification_token: nil)
    end

    def reset_password!(password)
      self.reset_password_token = nil
      self.password = password
    
      if password.match(/\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/)
        save(validate: false) # Skip all other validations, but password is already checked
      else
        raise "Password must include uppercase, lowercase, number, and special character"
      end
    end

    private

    def valid_social_media_links
      allowed_keys = %w[facebook instagram X youtube linkedin]
      if social_media_links.is_a?(Hash) && social_media_links.keys.any? { |key| !allowed_keys.include?(key) }
        errors.add(:social_media_links, "contains invalid keys")
      end
    end

    def parse_full_phone_number
      phone = Phonelib.parse(full_phone_number)
      self.full_phone_number = phone.sanitized
      self.country_code = phone.country_code
      self.phone_number = phone.raw_national
    end

    def create_razorpay_customer
      customer = BxBlockRazorpay::RazorpayIntegration.new.create_customer(self)
      update_column(:razorpay_customer_id, customer.id) if customer
    end

    def generate_api_key
      loop do
        @token = SecureRandom.base64.tr("+/=", "Qrt")
        break @token unless Account.exists?(unique_auth_id: @token)
      end
      self.unique_auth_id = @token
    end

    def set_black_listed_user
      if is_blacklisted_previously_changed?
        if is_blacklisted
          AccountBlock::BlackListUser.create(account_id: id)
        else
          blacklist_user.destroy
        end
      end
    end

    def skip_phone_validation?
      @skip_phone_validation
    end

    def create_default_settings
      create_setting
    end

    def current_subscription
      sub_scription_orders.success.last&.subscription  # Fetch latest successful subscription
    end
  end
end
