module BxBlockFavourites
  class Favourite < BxBlockFavourites::ApplicationRecord
    self.table_name = :favourites

# Protected Area Start
    belongs_to :favouriteable, polymorphic: true
# Protected Area End
  end
end
