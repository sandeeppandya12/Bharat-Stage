module BxBlockProductdescription
  class ProductdescriptionSerializer < BuilderBase::BaseSerializer
    attributes *[
      :name,
      :price,
      :description,
      :manufacture_date,
      :availability,
      :recommended,
      :on_sale,
      :sale_price,
      :product_id,

    ]
    attribute :images do |object, params|
    @host = (Rails.env.development? || Rails.env.test?) ? 'http://localhost:3000' : ENV['BASE_URL']
      if object.images.attached?
        object.images.map{ |image|
          {
            file_name: image.try(:blob).try(:filename),
            content_type: image.try(:blob).try(:content_type),
            id: image.id,
            url: @host + Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
          }
        }
      end
    end
  end
end