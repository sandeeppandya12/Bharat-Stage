module BxBlockEmergency
  class EmergencySerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :type, :phone_number, :is_active, :created_by, :updated_by, :created_at,
               :updated_at
  end
end
