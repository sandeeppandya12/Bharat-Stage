module AccountBlock
  class AccountsController < AccountBlock::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    include JSONAPI::Deserialization
    include CometchatUpdatable
    INNER_JOIN = "INNER JOIN accounts_sub_categories ON accounts.id = accounts_sub_categories.account_id"
    INNER_JOIN_SUB_CATEGORY = "INNER JOIN sub_categories ON accounts_sub_categories.sub_category_id = sub_categories.id"

    before_action :validate_json_web_token, only: [:search, :edit_profile, :edit_profile_skill, :edit_profile_picture, :edit_cover_photo, :delete_sub_category, :show_user_with_token]
    before_action :fetch_artist_profiles, only: [:index]
    before_action :validate_profile_params, only: [:edit_profile]
    before_action :find_account, only: [:edit_profile, :edit_profile_skill, :edit_profile_picture, :edit_cover_photo, :delete_sub_category, :show_user_with_token]
    
    def create
      existing_account = Account.find_by(email: account_params[:email].downcase)

      if existing_account
        return render json: { errors: [{ email: "Oops! It looks like this email address is already in use. Please try logging in or use a different email to sign up." }] }, status: :unprocessable_entity
      end

      existing_phone_number = Account.find_by(full_phone_number: ["91#{account_params[:full_phone_number]}", account_params[:full_phone_number]])
      
      if existing_phone_number
        return render json: { errors: [{ full_phone_number: "Oops! It looks like this phone_number address is already in use. Please try logging in or use a different phone number to sign up." }] }, status: :unprocessable_entity
      end
    
      modified_params = account_params.dup
      phone_number = modified_params[:full_phone_number]
    
      modified_params[:full_phone_number] = "+91#{phone_number}" if phone_number.present? && phone_number.length == 10
    
      @account = Account.new(modified_params)

       sms_otp = AccountBlock::SmsOtp.find_by(full_phone_number: "91#{params[:account][:full_phone_number]}")

      if sms_otp.nil? || sms_otp.activated == false 
        return render json: {messages: "First You have to verify mobile then create account "}, status: :unprocessable_entity
      end

      if @account.save
        AccountBlock::AccountMailer.welcome_email(@account).deliver_now!
        @account.first_name = "#{@account.first_name} #{@account.last_name}".strip
        comet_chat_user = BxBlockCometchatintegration::CometChatService.create_user(@account.id.to_s, @account.first_name)
        if comet_chat_user && comet_chat_user["data"] && comet_chat_user["data"]["uid"]
          auth_token_response = BxBlockCometchatintegration::CometChatService.generate_auth_token(@account.id.to_s)
          if auth_token_response['data']['authToken'] && auth_token_response['data']['uid']
            @account.update_columns(comet_chat_auth_token: auth_token_response['data']['authToken'], comet_chat_uid: auth_token_response['data']['uid'])
            render json: { message: "Thank you for signing up! An activation link has been sent to your email address #{@account.email}." }, status: :created
          else
            render json: { error: "CometChat Auth Token generation failed." }, status: :unprocessable_entity
          end
        else
          render json: { error: "CometChat user creation failed." }, status: :unprocessable_entity
        end
      else
        render json: { errors: @account.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def resend_verification_email
      @account = Account.find_by(email: params[:email].downcase)
    
      if @account.nil?
        return render json: { errors: [{ email: "No account found with this email." }] }, status: :not_found
      end
    
      if @account.activated?
        return render json: { message: "Your account is already verified." }, status: :unprocessable_entity
      end
    
      # Regenerate verification token (if needed)
      @account.update(verification_token: SecureRandom.hex(10)) unless @account.verification_token.present?

    
      # Send verification email
      AccountBlock::AccountMailer.welcome_email(@account).deliver_now!
    
      render json: { message: "A new verification email has been sent to #{@account.email}." }, status: :ok
    end
    
    
    def verify_account
      account = AccountBlock::Account.find_by(verification_token: params[:token])

      if account.nil?
        return render json: { error: "Invalid or expired token." }, status: :unprocessable_entity
      end

      account.verify_account_email
      BxBlockNotifications::Notification.create(
        account_id: account.id,     
        read_at: DateTime.now,
        headings: "verify user",
        contents: "Welcome to Bharat stage! We're glad to have you here. Start exploring and connect with talented artists and filmmakers."
      )
      render json: { message: "Account successfully verified!" }, status: :ok
    end

    def index
      if @accounts.present?
        @accounts = @accounts.where(activated:true, blocked: false)
        render json: { accounts: AccountSerializer.new(@accounts, serialization_options).serializable_hash,
          pagination: pagination_meta(@accounts)
        }, status: :ok
      else
        render json: {error: "accounts does not exist"}, status: :unprocessable_entity
      end
    end

    def edit_profile
      @account.instance_variable_set(:@skip_phone_validation, true)
      unless @account.update(account_params)
        return render json: { error: @account.errors.full_messages }, status: :unprocessable_entity
      end
      update_cometchat_profile(@account)
      render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
    end

    def edit_profile_skill
      ActiveRecord::Base.transaction do
        if params[:categories].present?
          params[:categories].each do |category_param|
            category = BxBlockCategories::Category.find_by(name: category_param[:name])
            return render json: { error: 'Category not present' }, status: :not_found unless category

            if @account.id.present? && category.id.present?
              @account.categories << category 
            end 

            category_param[:sub_categories]&.each do |sub_category_param|
              sub_category = BxBlockCategories::SubCategory.find_by(
                name: sub_category_param[:name],
                category_id: category.id
              )
              return render json: { error: 'SubCategory not present' }, status: :not_found unless sub_category

              experience_level = sub_category_param[:experience_level]
              next unless experience_level.present?

              if @account.id.present? && sub_category.id.present?
                record = AccountBlock::AccountsSubCategory.find_or_initialize_by(
                  account_id: @account.id,
                  sub_category_id: sub_category.id
                )
                record.update!(experience_level: experience_level)
              end
              record.update!(experience_level: experience_level)
            end
          end
        end
      end
      render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def delete_sub_category
      sub_category = BxBlockCategories::SubCategory.find_by(id: params[:sub_category_id])

      if sub_category.nil?
        return render json: { error: 'Subcategory not found' }, status: :not_found
      end

      record = AccountBlock::AccountsSubCategory.find_by(
        account_id: @account.id,
        sub_category_id: sub_category.id
      )

      if record
        record.destroy
        render json: { message: 'Subcategory deleted successfully.' }, status: :ok
      else
        render json: { error: 'Subcategory does not belong to the user.' }, status: :unprocessable_entity
      end
    end

    def destroy
      @account = AccountBlock::Account.find_by(id: params[:id])
  
      if @account.nil?
        render json: { error: 'Account not found' }, status: :not_found
        return
      end
  
      if @account.destroy
        render json: { message: 'Account deleted successfully.' }, status: :ok
      else
        render json: { error: 'Unable to delete the account.' }, status: :unprocessable_entity
      end
    end

    def edit_profile_picture
      if params[:user_image].present?
        image_type = ['image/jpeg', 'image/png']
        max_file_size = 10.megabytes

        if !image_type.include?(params[:user_image].content_type) || params[:user_image].size > max_file_size
          return render json: { 
            error: 'Maximum file size is 10MB and format should be JPG / JPEG / PNG.' 
          }, status: :unprocessable_entity
        end

        @account.user_image.purge if @account.user_image.attached?
        @account.user_image.attach(
          io: params[:user_image].tempfile, 
          filename: params[:user_image].original_filename, 
          content_type: params[:user_image].content_type
        )
        @account.save!(validate:false)
 
        unless @account.user_image.attached?
          return render json: { error: 'Failed to upload file. Please try again.' }, status: :unprocessable_entity
        end
      else
        return render json: { error: 'Image not attached.' }, status: :unprocessable_entity
      end
      render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
    end

    def edit_cover_photo
      if params[:cover_photo].present?
        image_type = ['image/jpeg', 'image/png']
        max_file_size = 10.megabytes

        if !image_type.include?(params[:cover_photo].content_type) || params[:cover_photo].size > max_file_size
          return render json: { 
            error: 'Maximum file size is 10MB and format should be JPG / JPEG / PNG.' 
          }, status: :unprocessable_entity
        end

        @account.cover_photo.purge if @account.cover_photo.attached?
        @account.cover_photo.attach(
          io: params[:cover_photo].tempfile, 
          filename: params[:cover_photo].original_filename, 
          content_type: params[:cover_photo].content_type
        )
         @account.save!(validate:false)
 
        unless @account.cover_photo.attached?
          return render json: { error: 'Failed to upload file. Please try again.' }, status: :unprocessable_entity
        end
      else
        return render json: { error: 'Image not attached.' }, status: :unprocessable_entity
      end
      render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
    end

    def show
      @account = AccountBlock::Account.find_by(id: params[:id])
      if @account.present?
        render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
      else
        render json: { error: 'Account not found' }, status: :not_found 
      end
    end

    def states
      country = ISO3166::Country.new('IN')
      if country.present?
        @states = country.states.map { |_k, v| v['name'] }.compact
        render json: @states, status: :ok
      else
        render json: { errors: 'Country not found' }, status: :not_found
      end
    end

    def show_user_with_token
      render json: EmailAccountSerializer.new(@account).serializable_hash, status: :ok
    end

    private

    def fetch_artist_profiles
      return render json: { error: "Please enter at least 3 characters for search" }, status: :bad_request if params[:name].present? && params[:name].length < 3
			@accounts = params[:name].present? ? Account.search_by_name(params[:name]) : Account.all
      apply_filters
      apply_sorting

      page_number = params[:pag].to_i.positive? ? params[:pag].to_i : 1
      per_page = params[:per].to_i.positive? ? params[:per].to_i : 20
      @accounts = @accounts.page(page_number).per(per_page)
		end

    def apply_filters
      @accounts = @accounts.where(gender: params[:gender]) if params[:gender].present?
      if params[:age_range].present?
        age_conditions = params[:age_range].map do |range|
          min_age, max_age = range.split('-').map(&:to_i)
          "(age BETWEEN #{min_age} AND #{max_age})"
        end

        @accounts = @accounts.where(age_conditions.join(' OR '))
      end
      @accounts = @accounts.where("LOWER(locations) = ?", params[:locations].downcase) if params[:locations].present?
      if params[:language].present?
        language_conditions = params[:language].map do |language|
          ActiveRecord::Base.sanitize_sql_array(["? = ANY(languages)", language])
        end

        @accounts = @accounts.where(language_conditions.join(' OR '))
      end

      if params[:sub_categories].present?
        sub_categories = params[:sub_categories]
        sub_categories = JSON.parse(sub_categories) if sub_categories.is_a?(String)

        category_names = sub_categories.keys.map(&:downcase)
        categories = BxBlockCategories::Category.where("LOWER(name) IN (?)", category_names)
        category_ids = categories.pluck(:id)

        sub_category_ids = []

        sub_categories.each do |category_name, sub_category_names|
          category = categories.find { |c| c.name.downcase == category_name.downcase }
          next unless category 
          
          valid_subcategories = BxBlockCategories::SubCategory.where(
            "LOWER(name) IN (?) AND category_id = ?", 
            sub_category_names.map(&:downcase), category.id
          ).pluck(:id)

          sub_category_ids.concat(valid_subcategories)
        end

        @accounts = @accounts.joins(:categories, :sub_categories)
                             .where(categories: { id: category_ids })
                             .where(sub_categories: { id: sub_category_ids })
                             .distinct
      end

    end

    def apply_sorting
			case params[:sort_by]
			when "name(A-Z)"
				@accounts = @accounts.order(Arel.sql("first_name ASC"))
			when "name(Z-A)"
				@accounts = @accounts.order(Arel.sql("first_name DESC"))
   
      when "experience(Beginner-Expert)"
        @accounts = @accounts
            .select('accounts.*, MIN(accounts_sub_categories.experience_level) AS min_experience_level')
            .joins(INNER_JOIN)
            .joins(INNER_JOIN_SUB_CATEGORY)
            .group('accounts.id')
            .order('min_experience_level ASC NULLS LAST')
    
      when "experience(Expert-Beginner)"
        @accounts = @accounts
            .select('accounts.*, MAX(accounts_sub_categories.experience_level) AS max_experience_level')
            .joins(INNER_JOIN)
            .joins(INNER_JOIN_SUB_CATEGORY)
            .group('accounts.id')
            .order('max_experience_level DESC NULLS LAST')
			end
		end

    def pagination_meta(accounts)
      {
        current_page: accounts.current_page,
        next_page: accounts.next_page,
        # prev_page: accounts.prev_page,
        total_pages: accounts.total_pages,
        total_count: accounts.total_count
      }
    end

    def account_params
      params.require(:account).permit(
        :first_name, :last_name, :email, :full_phone_number, :password, :password_confirmation, 
        :roles, :terms_accepted, :country_code, :phone_number, :activated, :device_id, 
        :unique_auth_id, :type, :user_name, :platform, :user_type, :app_language_id, 
        :last_visit_at, :is_blacklisted, :suspend_until, :status, :full_name, :role_id, 
        :gender, :date_of_birth, :age, :is_mobile_verified, :reset_password_token, 
        :reset_password_sent_at, :reset_token_expires_at, :description, :height, :weight, 
        :locations, :user_role, :blocked, 
        languages: [], portfolio_links: [], social_media_links: []
      )
    end

    def encode(id)
      BuilderJsonWebToken.encode id
    end

    def validate_profile_params
      %i[first_name last_name].each do |field|
        value = params[:account][field]
        return "#{field.to_s.humanize} is invalid" unless value.present? && value.length <= 30 && value.match?(/\A[a-zA-Z]+\z/)
      end
      nil
    end

    def find_account
      @account = AccountBlock::Account.find_by(id: @token.id)
      render json: { error: 'Account not found' }, status: :not_found unless @account
    end

    def serialization_options
      { params: { host: request.protocol + request.host_with_port } }
    end

  end
end
