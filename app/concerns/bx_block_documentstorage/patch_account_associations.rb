module BxBlockDocumentstorage
  module PatchAccountAssociations
    extend ActiveSupport::Concern

    included do
      has_many :galleries, class_name: 'BxBlockDocumentstorage::Gallery', dependent: :destroy
    end
  end
end
