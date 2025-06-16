# == Schema Information
#
# Table name: coordinates
#
#  id             :bigint           not null, primary key
#  latitude       :string
#  longitude      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  addressable_id :integer
#
module BxBlockFedexIntegration
  class Coordinate < BxBlockFedexIntegration::ApplicationRecord
    self.table_name = :coordinates

# Protected Area Start
    belongs_to :addressable, class_name: "BxBlockFedexIntegration::Addressable"
# Protected Area End
  end
end
