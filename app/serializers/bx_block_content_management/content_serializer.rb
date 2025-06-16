module BxBlockContentManagement
  class ContentSerializer < BuilderBase::BaseSerializer
    attributes *[
      :title,
      :description,
      :created_at,
      :updated_at
    ]

    # attribute :images do |object|
    #   @host = Rails.env.development? ? 'http://localhost:3000' : ENV['BASE_URL']
    #   if object.images.attached?
    #     object.images.map { |image|
    #       {
    #         id: image.id,
    #         url: @host + Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true),
    #         type: "images",
    #         filename: image.filename
    #       }
    #     }
    #   else
    #     ''
    #   end
    # end

    attribute :image do |object, params|
      host = params[:host] || ''
      object.image.attached? ? host+Rails.application.routes.url_helpers.rails_blob_url(object.image, only_path: true) : ""
    end

  end
end
