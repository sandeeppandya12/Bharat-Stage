module AccountBlock
  class AccountSerializer < BuilderBase::BaseSerializer
    attributes(:activated, :country_code, :email, :first_name, :full_phone_number, :last_name, :height, :weight, :roles, :blocked , :activated, :type, :status, :role_id, :gender, :full_name, :age, :date_of_birth, :locations, :languages, :description, :created_at, :updated_at, :unique_auth_id, :social_media_links)
    
    attribute :full_name do |object|
      "#{object.first_name} #{object.last_name}".strip
    end

    attribute :country_code do |object|
      country_code_for object
    end

    attribute :categories do |object|
      object.sub_categories.with_experience_level.select { |sub_category| sub_category.category.present? }.group_by { |sub_category| sub_category.category&.name }.map do |category_name, sub_categories|
        {
          name: category_name,
          sub_categories: sub_categories.map do |sub_category|
            {
              id: sub_category.id,
              name: sub_category.name,
              experience_level: AccountBlock::AccountsSubCategory.experience_levels.key(sub_category.experience_level)
            }
          end
        }
      end
    end

    class << self
      private

      def country_code_for(object)
        return nil unless Phonelib.valid?(object.full_phone_number)
        Phonelib.parse(object.full_phone_number).country_code
      end

      def phone_number_for(object)
        return nil unless Phonelib.valid?(object.full_phone_number)
        Phonelib.parse(object.full_phone_number).raw_national
      end
    end

    attribute :user_careers do |object, params|
      BxBlockProfile::UserCareerSerializer.new(object.user_careers, { params: params }).serializable_hash[:data].map { |d| d[:attributes] }
    end

    attribute :user_educations do |object|
      BxBlockProfile::UserEducationSerializer.new(object.user_educations).serializable_hash[:data].map { |d| d[:attributes] }
    end

    attribute :user_links do |object|
      object.user_links.each_with_object({}) do |link, hash|
        hash[link.key] = link.value
      end
    end

    attribute :user_image_url do |object, params|
      if object.user_image.attached?
        host = params[:host] || Rails.application.config.default_url_options[:host]
        Rails.application.routes.url_helpers.rails_blob_url(object.user_image, host: host)
      else
        ""
      end
    end
    
    attribute :cover_photo do |object, params|
      if object.cover_photo.attached?
        host = params[:host] || Rails.application.config.default_url_options[:host]
        Rails.application.routes.url_helpers.rails_blob_url(object.cover_photo, host: host)
      else
        ""
      end
    end

    attribute :upload_media do |object, params|
      host = params[:host] || ''
      if object.upload_media.attached?
        object.upload_media.map.with_index do |media, index|
          {
            id: media.id,
            # index: index, 
            url: host + Rails.application.routes.url_helpers.rails_blob_url(media, only_path: true),
            filename: media.filename.to_s,
            content_type: media.content_type
          }
        end
      else
        []
      end
    end

  end
end
