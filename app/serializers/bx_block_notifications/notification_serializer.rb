module BxBlockNotifications
  class NotificationSerializer
    include FastJsonapi::ObjectSerializer
    attributes *[
        :id,
        :created_by,
        :headings,
        :title,
        :contents,
        :app_url,
        :is_read,
        :chat_notification,
        :read_at,
        :created_at,
        :updated_at,
        :account
    ]

    attribute :user_image_url do |object, params|
      if object.account&.user_image&.attached?
        host = params[:host] || Rails.application.config.default_url_options[:host]
        host + Rails.application.routes.url_helpers.rails_blob_url(object.account.user_image, only_path: true)
      else
        ""
      end
    end

  end
end
