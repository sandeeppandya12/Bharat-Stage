module BxBlockContentManagement
  class TestimonialSerializer < BuilderBase::BaseSerializer
    attributes *[
      :name,
      :designation,
      :content,
      :created_at,
      :updated_at
    ]

    attribute :profile_image do |object, params|
      if object.profile_image.attached?
        host = params[:host] || Rails.application.config.default_url_options[:host]
        Rails.application.routes.url_helpers.rails_blob_url(object.profile_image, host: host)
      else
        ""
      end
    end

 end
end