module BxBlockDocumentstorage
	class Gallery < ApplicationRecord
		self.table_name = 'bx_block_documentstorage_galleries'
		DOCUMENT_TYPES = ['application/pdf'].freeze
		DOCUMENT_EXTENSIONS = ['pdf'].freeze
		enum gallery_type: { documents: 0, library: 1, personal: 2 }
# Protected Area Start
		has_many_attached :gallery_medias
		belongs_to :account, class_name: 'AccountBlock::Account'
		has_many :folders, class_name: 'BxBlockDocumentstorage::Folder'
# Protected Area End
		validates :gallery_medias, attached: true, content_type: DOCUMENT_TYPES, on: :update, if: proc { gallery_type.eql?('documents') }
	end
end
