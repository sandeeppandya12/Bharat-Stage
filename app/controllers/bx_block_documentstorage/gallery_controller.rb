module BxBlockDocumentstorage
	class GalleryController < BuilderBase::ApplicationController
		include ActiveStorage::Blob::Analyzable
	    before_action :set_gallery, only: %i[show update destroy_media_file update_file_name]
	    
	    def create
	        @gallery = current_user.galleries.first
	      if  @gallery.present?
	        render json: { gallery: @gallery, message: 'Gallery Already Created'}, status: :unprocessable_entity
	      else
	        @gallery = BxBlockDocumentstorage::Gallery.new(account_id:params[:account_id])
	        if @gallery.save
	          render json: @gallery, status: :created
	        end
	      end
	    end

	    def index 
	      data = current_user.galleries
	      render json: BxBlockDocumentstorage::GallerySerializer.new(data, serialization_options).serializable_hash, status: :ok
	    end

	    def show
	      render json: BxBlockDocumentstorage::GallerySerializer.new(@gallery).serializable_hash, status: :ok
	    end

	    def update
	      gallery_media = params[:gallery_medias]
	      if gallery_media.present? && validate_gallery_media_extensions(gallery_media)
	        return render json: { errors: 'Invalid file extension, only pdf is allowed' }, status: :unprocessable_entity
	      else
	        @gallery.gallery_medias.attach(gallery_media)
	        render json: BxBlockDocumentstorage::GallerySerializer.new(@gallery, serialization_options).serializable_hash, status: :ok
	      end
	    end

	    def update_file_name
	      blob_id = params.dig(:data, :attributes, :blob_id)
	      filename = params.dig(:data, :attributes, :filename)

	      if validate_file_extension(filename)
	        return render json: { errors: 'Invalid filename, pdf is only valid file extension' },
	                      status: :unprocessable_entity
	      end
	      attachment = @gallery.gallery_medias.where(blob_id: blob_id).first if blob_id.present?
	      return render json: { errors: 'File not found' } unless attachment.present?

	      render json: { message: 'File name updated' }, status: :ok if attachment.blob.update(filename: filename)
	    end

	    def destroy_media_file
	      attachment = @gallery.gallery_medias.where(blob_id: params.dig(:data, :attributes, :blob_id))
	      if attachment.present?
	        attachment.purge
	        render json: { message: 'Successfully deleted the file' }
	      else
	        render json: { errors: 'File not found' }, status: :unprocessable_entity
	      end
	    end

	    def account_gallery
	      account = AccountBlock::Account.find(params[:account_id])
	      gallery = account.galleries.where(gallery_type: params[:gallery_type])
	      render json: BxBlockDocumentstorage::GallerySerializer.new(gallery, serialization_options).serializable_hash, status: :ok
	    end

	    private

	    def current_user
	      @current_user = AccountBlock::Account.find(params[:account_id])
	    end

	    def set_gallery
	      @gallery = BxBlockDocumentstorage::Gallery.find_by_id(params[:id])
	      return render json: { errors: 'Gallery not found' } unless @gallery.present?
	    end

	    def validate_file_extension(filename)
	      filextension = filename.split('.').last
	      return true if !filextension.nil? && !filextension.in?(BxBlockDocumentstorage::Gallery::DOCUMENT_EXTENSIONS)
	    end

	    def validate_gallery_media_extensions(media)
	      invalid_extensions = media.any? { |file| File.extname(file.original_filename) != '.pdf' }
	      invalid_extensions
	    end

	    def serialization_options
	      { params: { host: request.base_url } }
	    end
	end
end
