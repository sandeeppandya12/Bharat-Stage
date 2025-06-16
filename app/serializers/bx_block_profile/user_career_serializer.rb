module BxBlockProfile
  class UserCareerSerializer < BuilderBase::BaseSerializer
    attributes :id, :project_name, :role, :start_date, :end_date, :is_ongoing, :start_year, :end_year,
               :location, :project_link, :description, :account_id

    attribute :career_images_urls do |object, params|
      if object.career_image.attached?
        host = params[:host] || Rails.application.config.default_url_options[:host]
        host + Rails.application.routes.url_helpers.rails_blob_url(object.career_image, only_path: true)
      else
        ""
      end
    end

    attribute :duration do |object|
      object.duration_in_words
    end
  end
end
