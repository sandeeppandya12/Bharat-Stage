module BxBlockProfile
    class UserProfileSerializer < BuilderBase::BaseSerializer
      attributes *[
        :first_name,
        :last_name,
        :description,
        :languages,
        :portfolio_links,
        :social_media_links,
        :height,
        :weight,
        :location,
        :gender,
        :role,
        :age,
        :experience_level
      ]

      attribute :full_name do |object|
        "#{object.first_name} #{object.last_name}".strip
      end
    end
  end
  