module AccountBlock
  class EmailAccountSerializer
    include FastJsonapi::ObjectSerializer
    attributes(:activated, :country_code, :email, :first_name, :full_phone_number, :last_name, :height, :weight, :roles, :blocked , :activated, :type, :status, :role_id, :gender, :full_name, :age, :date_of_birth, :locations, :languages, :description, :created_at, :updated_at, :unique_auth_id, :social_media_links)
    
    attribute :full_name do |object|
      "#{object.first_name} #{object.last_name}".strip
    end

    attribute :categories do |object|
      object.sub_categories.with_experience_level.group_by { |sub_category| sub_category.category.name }.map do |category_name, sub_categories|
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

    attribute :user_careers do |object|
      object.user_careers.map do |career|
        {
          id: career.id,
          project_name: career.project_name,
          role: career.role,
          start_date: career.start_date,
          end_date: career.end_date,
          is_ongoing: career.is_ongoing,
          location: career.location,
          project_link: career.project_link,
          description: career.description,
          start_year: career.start_year,
          end_year: career.end_year
        }
      end
    end
    
    attribute :user_educations do |object|
      object.user_educations.map do |education|
        {
          id: education.id,
          institute_name: education.institute_name,
          qualification: education.qualification,
          start_date: education.start_date,
          end_date: education.end_date,
          is_ongoing: education.is_ongoing,
          location: education.location,
          start_year: education.start_year,
          end_year: education.end_year
        }
      end
    end

    attribute :user_links do |object|
      object.user_links.each_with_object({}) do |link, hash|
        hash[link.key] = link.value
      end
    end

    attribute :user_image_url do |object, params|
      host = params[:host] || ''
      object.user_image.attached? ? host+Rails.application.routes.url_helpers.rails_blob_url(object.user_image, only_path: true) : ""
    end

    attribute :cover_photo do |object, params|
      host = params[:host] || ''
      object.cover_photo.attached? ? host+Rails.application.routes.url_helpers.rails_blob_url(object.cover_photo, only_path: true) : ""
    end

  end
end
