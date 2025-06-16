module BxBlockDocumentstorage
	class FolderController < BuilderBase::ApplicationController
		include ActiveStorage::Blob::Analyzable
	    before_action :set_gallery
	    before_action :set_folder, except: %i[create]
	    
	    def create
	      folder = @gallery.folders.new(folder_params)
	      if folder.save
	        render json: BxBlockDocumentstorage::FolderSerializer.new(folder).serializable_hash, status: :ok
	      else
	        render json: { errors: folder.errors }, status: :unprocessable_entity
	      end
	    end

	    def show 
	      return unless @folder.present?
	      render json: BxBlockDocumentstorage::FolderSerializer.new(@folder, serialization_options).serializable_hash, status: :ok
	    end

	    def update
	      folder_media = params[:folder_media]
	      if folder_media.present? && validate_folder_media_extensions(folder_media)
	        return render json: { errors: 'Invalid file extension, only pdf is allowed' }, status: :unprocessable_entity
	      else
	        @folder.folder_medias.attach(folder_media) 
	        render json: BxBlockDocumentstorage::FolderSerializer.new(@folder, serialization_options).serializable_hash, status: :ok
	      end
	    end

	    def update_file_name
	      blob_id = params.dig(:data, :attributes, :blob_id)
	      attachment = @folder.folder_medias.where(blob_id: blob_id).first if blob_id.present?
	      return render json: { errors: 'File not found' } unless attachment.present?

	      filename = params.dig(:data, :attributes, :filename)

	      if validate_file_extension(filename)
	        return render json: { errors: 'Invalid filename, pdf is only valid file extension' },
	        status: :unprocessable_entity
	      end
	      return unless attachment.blob.update(filename: filename)

	      render json: { message: 'File name updated' }, status: :ok
	    end

	    def update_folder_name
	      folder_name = params.dig(:data, :attributes, :folder_name)
	      return render json: { errors: 'Folder name required' } unless folder_name.present?
	      
	      @folder.update(folder_name: folder_name)
	      render json: { message: 'Folder name updated succesfuly' }, status: :ok
	    end

	    def destroy
	      @folder.destroy
	      render json: { message: 'Successfully deleted the folder' }
	    end

	    def destroy_media_file
	      attachment = @folder.folder_medias.where(blob_id: params.dig(:data, :attributes, :blob_id))
	      if attachment.present?
	        attachment.purge
	        render json: { message: 'Successfully deleted the file' }
	      else
	        render json: { errors: 'File not found' }
	      end
	    end

	    def set_gallery
	      @gallery = BxBlockDocumentstorage::Gallery.find_by_id(params.dig(:data, :attributes, :gallery_id))
	      return render json: { errors: 'Gallery not found' } unless @gallery.present?
	    end

	    def set_folder
	      @folder = @gallery.folders.find_by_id(params[:id])
	      return render json: { errors: 'Folder not found' } unless @folder.present?
	    end

	    def validate_file_extension(filename)
	      filextension = filename.split('.').last
	      return true if !filextension.nil? && !filextension.in?(BxBlockDocumentstorage::Gallery::DOCUMENT_EXTENSIONS)
	    end

	    def validate_folder_media_extensions(media)
	      invalid_extensions = media.any? { |file| File.extname(file.original_filename) != '.pdf' }
	      invalid_extensions
	    end

	    def serialization_options
	      { params: { host: request.base_url } }
	    end

	    def folder_params
	      params.require(:data).require(:attributes).permit(:folder_id, :folder_name, :gallery_id, :gallery_type, :folder_medias, :blob_id, :filename, :folder_type)
	    end
	end
end
