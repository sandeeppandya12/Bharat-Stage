module BxBlockContactUs
  class ContactSerializer < BuilderBase::BaseSerializer
    attributes :first_name, :last_name, :email, :full_phone_number, :subject, :message

    attribute :contact_images_urls do |object|
      object.contact_images.map do |image|
        Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
      end
    end
  end
end
