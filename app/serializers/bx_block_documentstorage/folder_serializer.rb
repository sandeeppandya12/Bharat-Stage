module BxBlockDocumentstorage
	class FolderSerializer < BuilderBase::BaseSerializer

	  attributes(:folder_name, :folder_type)
    attribute :gallery, &:gallery
    attribute :folder_medias do |object, params|
    data = []
    host = params[:host] || ''
	    if object.folder_medias.attached?
	      object.folder_medias.each do |file|
	        data << { url: host + Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true),
	                  blob_id: file.blob_id,
	                  filename: file.blob&.filename.to_s }
	      end
	    end
    data
	  end
	end
end
