module BxBlockEmergency
  class ErrorSerializer < BuilderBase::BaseSerializer
    attribute :errors do |obj|
      obj.errors.as_json
    end
  end
end
