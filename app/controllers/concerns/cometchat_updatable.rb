module CometchatUpdatable
  extend ActiveSupport::Concern

  def update_cometchat_profile(account)
    return unless account.comet_chat_uid.present?

    full_name = "#{account.first_name} #{account.last_name}".strip

    begin
      BxBlockCometchatintegration::ChatService.update_user_profile_name(account.comet_chat_uid, full_name)
    rescue StandardError => e
      Rails.logger.error("Failed to update CometChat profile for Account ID #{account.id}: #{e.message}")
    end
  end
end