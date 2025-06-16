module BxBlockDocumentstorage
	class Folder < ApplicationRecord
    self.table_name = 'bx_block_documentstorage_folders'
    validates_uniqueness_of :folder_name
    validates :folder_medias, content_type: BxBlockDocumentstorage::Gallery::DOCUMENT_TYPES, on: :update, if: proc { gallery.gallery_type.eql?('documents') }
# Protected Area Start
    belongs_to :gallery, class_name: 'BxBlockDocumentstorage::Gallery'
    has_many_attached :folder_medias
# Protected Area End
    enum folder_type: { document: 0 , photo: 2, voice: 1 }
	end
end
