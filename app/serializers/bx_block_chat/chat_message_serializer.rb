module BxBlockChat
  class ChatMessageSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer

    attributes :id, :message, :account_id, :chat_id, :created_at, :updated_at, :is_mark_read

    attribute :attachments do |object, params|
      host = params[:host] || ""
      if object.attachments.attached?
        object.attachments.map { |attachment|
          {
            id: attachment.id,
            url: host + Rails.application.routes.url_helpers.rails_blob_url(
              attachment, only_path: true
            )
          }
        }
      end
    end
  end
end
