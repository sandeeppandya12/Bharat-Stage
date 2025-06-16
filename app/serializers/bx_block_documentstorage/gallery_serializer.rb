module BxBlockDocumentstorage
  class GallerySerializer < BuilderBase::BaseSerializer

    attributes(:gallery_type)
    attribute :gallery_medias do |object, params|
      data = []
      host = params[:host] || ''
      if object.gallery_medias.attached?
        object.gallery_medias.each do |file|
          data << { url: host + Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true),
                    blob_id: file.blob_id,
                    filename: file.blob&.filename.to_s }
        end
      end
      data
    end
    attributes :folder do |object, _params|
      BxBlockDocumentstorage::FolderSerializer.new(object&.folders)
    end
  end
end
