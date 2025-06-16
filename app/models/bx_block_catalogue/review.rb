module BxBlockCatalogue
  class Review < BxBlockCatalogue::ApplicationRecord
    self.table_name = :catalogue_reviews

# Protected Area Start
    belongs_to :catalogue
# Protected Area End
  end
end
