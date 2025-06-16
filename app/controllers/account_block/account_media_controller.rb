module AccountBlock
  class AccountMediaController < AccountBlock::ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    include JSONAPI::Deserialization
    LOGGER = Logger.new(Rails.root.join('log', 'upload_errors.log'))

    MAX_PHOTO_SIZE = 10.megabytes
    MAX_VIDEO_SIZE = 100.megabytes
    MAX_VIDEOS_SIZE = 500.megabytes
    MAX_PHOTO_COUNT = 20
    MAX_VIDEO_COUNT = 5

    ALLOWED_TYPES = {
      'image/jpeg' => MAX_PHOTO_SIZE,
      'image/jpg' => MAX_PHOTO_SIZE,
      'image/png' => MAX_PHOTO_SIZE,
      'image/svg+xml' => MAX_PHOTO_SIZE,
      'video/mp4' => MAX_VIDEO_SIZE,
      'video/x-msvideo' => MAX_VIDEO_SIZE,
      'audio/mpeg' => MAX_VIDEO_SIZE,
      'application/pdf' => MAX_PHOTO_SIZE
    }.freeze

    before_action :validate_json_web_token, only: %i[upload_media portfolio_links social_media_links delete_profile_image delete_cover_image delete_specific_media update_specific_media]
    before_action :find_account, only: %i[upload_media portfolio_links social_media_links delete_profile_image delete_cover_image delete_specific_media update_specific_media]
    before_action :find_image, only: %i[delete_specific_media update_specific_media]
    before_action :validate_video_count, only: [:upload_media, :update_specific_media]

    def upload_media
      @account.skip_phone_validation = true
      @account.assign_attributes(account_params.except(:upload_media))

      return unless account_params[:upload_media].present?

      photos, videos, audios, pdfs, errors = process_media(account_params[:upload_media])

      if errors.present?
        return render json: { error: errors.join(' ') }, status: :unprocessable_entity
      end

      attach_media(photos + videos + audios + pdfs)

      if @account.save(validate: false) && @account.upload_media.attached?
        render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
      else
        render json: { error: 'Failed to upload files. Please try again.' }, status: :unprocessable_entity
      end
    end

    def portfolio_links
      @account.skip_phone_validation = true
      update_user_links

      if @account.save
        render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
      end
    end

    def social_media_links
      @account.skip_phone_validation = true

      if @account.update(social_media_links: social_media_params)
        render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
      end
    end

    def delete_profile_image
      if @account.user_image.attached?
        @account.user_image.purge
        render json: { message: 'Profile picture deleted successfully.' }, status: :ok
      else
        render json: { error: 'No profile picture found.' }, status: :unprocessable_entity
      end 
    end

    def delete_cover_image
      if @account.cover_photo.attached?
        @account.cover_photo.purge
        render json: { message: 'Cover photo deleted successfully.' }, status: :ok
      else
        render json: { error: 'No cover photo found.' }, status: :unprocessable_entity
      end 
    end

    def delete_specific_media
      if @attachment
        @attachment.purge
        render json: { message: 'File deleted successfully.' }, status: :ok
      end
    end

    def update_specific_media
      @account.skip_phone_validation = true
      @account.assign_attributes(account_params.except(:upload_media))

      file = params[:upload_media]
      return render_error('No file provided.') unless file

      photos, videos, errors = process_media(file)
      return render json: { error: errors.join(' ') }, status: :unprocessable_entity if errors.present?

      begin
        @attachment.purge
        @account.upload_media.attach(
          io: file.tempfile,
          filename: file.original_filename,
          content_type: file.content_type
        )
        if @account.save && @account.upload_media.attached?
          render json: AccountSerializer.new(@account, serialization_options).serializable_hash, status: :ok
        else
          render json: { error: 'Failed to upload file. Please try again.' }, status: :unprocessable_entity
        end
      rescue ActiveStorage::IntegrityError => e
        Rails.logger.error "IntegrityError: #{e.message}"
        render json: { error: 'File upload failed due to integrity issues' }, status: :unprocessable_entity
      end
    end

    private

    def find_image
      @attachment = @account.upload_media.find_by(id: params[:id])
      render json: { error: 'File not found.' }, status: :unprocessable_entity unless @attachment.present?
    end

    def process_media(media_files)
      photos = []
      videos = []
      pdfs = []
      audios = []
      errors = []

      media_files = [media_files] unless media_files.is_a?(Array)

      media_files.each do |file|
        unless ALLOWED_TYPES.keys.include?(file.content_type)
          errors << "Only support .JPEG, .JPG, .PNG, .SVG, .MP4, .AVI, .MP3 and PDF files."
          next
        end

        if file.size > ALLOWED_TYPES[file.content_type]
          errors << "The maximum file size for photos is 10MB and videos is 100MB."
          next
        end

        case file.content_type
        when /^image/
          photos << file
        when /^video/
          videos << file
        when "application/pdf"
          pdfs << file 
        when "audio/mpeg" 
          audios << file
        end
      end

      errors += validate_media_count(photos, videos, pdfs, audios)
      [photos, videos, pdfs, audios, errors]
    end

    def validate_media_count(photos, videos, pdfs, audios)
      errors = []
      errors << "Maximum #{MAX_PHOTO_COUNT} images are allowed." if photos.size > MAX_PHOTO_COUNT
      errors << "Maximum 5 pdfs are allowed." if pdfs.size > 5 
      errors << "Maximum 5 audios are allowed." if audios.size > 5 
     
      errors
    end

    def validate_video_count
      videos = account_params[:upload_media]&.select do |file|
        file.content_type.start_with?('video') && valid_file_type?(file)
      end || []

      if videos.size > MAX_VIDEO_COUNT
        log_video_error(videos)
        render json: { error: "Maximum #{MAX_VIDEO_COUNT} videos are allowed." }, status: :unprocessable_entity
      end

      if videos.sum(&:size) > MAX_VIDEOS_SIZE
       return render json: { errors: "The combined size of all videos should not exceed 500 MB." }, status: :unprocessable_entity
      end
    end

    def attach_media(files)
      files.each do |file|
        @account.upload_media.attach(
          io: file.tempfile,
          filename: file.original_filename,
          content_type: file.content_type
        )
      end
    end

    def log_video_error(videos)
      LOGGER.error("❌ Video Error: Maximum #{MAX_VIDEO_COUNT} videos are allowed.")
      videos.each do |video|
        LOGGER.error("📹 Video Data: #{video.original_filename}, #{video.content_type}, #{video.size || 'Unknown'} bytes")
      end
    end

    def update_user_links
      user_links_params.each do |key, value|
        link = @account.user_links.find_or_initialize_by(key: key)
        link.value = value.presence
        link.save(validate: false)
      end
    end

    def account_params
      params.permit(upload_media: [])
    end

    def find_account
      @account = AccountBlock::Account.find_by(id: @token.id)
      render json: { error: 'Account not found' }, status: :not_found unless @account
    end

    def social_media_params
      params.require(:social_media_links).permit(:facebook, :instagram, :X, :youtube, :linkedin)
    end

    def user_links_params
      params.require(:account).permit(user_links: {})[:user_links] || {}
    end

    def valid_file_type?(file)
      ALLOWED_TYPES.keys.include?(file.content_type)
    end

    def render_error(message)
      render json: { error: message }, status: :unprocessable_entity
    end

    def serialization_options
      { params: { host: request.protocol + request.host_with_port } }
    end

  end
end
