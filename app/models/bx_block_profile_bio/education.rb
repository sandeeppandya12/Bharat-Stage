# frozen_string_literal: true

module BxBlockProfileBio
  # education model
  class Education < BxBlockProfileBio::ApplicationRecord
    self.table_name = :educations

    include Wisper::Publisher
# Protected Area Start
    belongs_to :profile_bio
# Protected Area End
  end
end
