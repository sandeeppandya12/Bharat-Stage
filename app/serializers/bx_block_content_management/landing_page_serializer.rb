module BxBlockContentManagement
  class LandingPageSerializer < BuilderBase::BaseSerializer
    attributes *[
      :title,
      :description,
      :created_at,
      :updated_at
    ]

    attribute :image do |object, params|
      if object.image.attached?
        host = params[:host] || Rails.application.config.default_url_options[:host]
        Rails.application.routes.url_helpers.rails_blob_url(object.image, host: host)
      else
        ""
      end
    end

 end
end