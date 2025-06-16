module BxBlockCatalogue
  class CataloguesTag < BxBlockCatalogue::ApplicationRecord
    self.table_name = :catalogues_tags

# Protected Area Start
    belongs_to :catalogue
    belongs_to :tag, foreign_key: "catalogue_tag_id"
# Protected Area End
  end
end
