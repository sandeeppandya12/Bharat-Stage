module BxBlockUploadMedia
  class Media < ApplicationRecord
    self.table_name = :media
# Protected Area Start
    belongs_to :imageable, polymorphic: true
# Protected Area End
    enum status: [:pending, :rejected, :approved]
  end
end
