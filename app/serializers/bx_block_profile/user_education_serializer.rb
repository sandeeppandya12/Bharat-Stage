module BxBlockProfile
    class UserEducationSerializer < BuilderBase::BaseSerializer
        attributes :id, :institute_name, :qualification, :start_date, :end_date, :start_year, :end_year,
        :is_ongoing, :location, :account_id

        attribute :duration do |object|
          object.duration_in_words
        end
    end
end