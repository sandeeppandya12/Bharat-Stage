module BxBlockSettings
  class SettingSerializer < BuilderBase::BaseSerializer
    attributes :id, :title, :name, :account_id, :two_factor_enabled, 
               :email_notification, :in_app_notification, :desktop_notification, :chat_notification

    attribute :first_name do |setting|
      setting.account&.first_name
    end

    attribute :last_name do |setting|
      setting.account&.last_name
    end

    attribute :email do |setting|
      setting.account&.email
    end

    attribute :full_phone_number do |setting|
      setting.account&.full_phone_number
    end

    attribute :roles do |setting|
      setting.account&.roles
    end
  end
end
