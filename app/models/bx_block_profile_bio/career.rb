# frozen_string_literal: true

module BxBlockProfileBio
  # carrer model
  class Career < BxBlockProfileBio::ApplicationRecord
    self.table_name = :careers
    include Wisper::Publisher

# Protected Area Start
    belongs_to :profile_bio

# Protected Area End
    enum sector: %i[Government Private], _prefix: :sector
  end
end
