class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :trackable

  before_save :send_admin_analytic_event

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "current_sign_in_at", "current_sign_in_ip", "email", "encrypted_password", "id", "last_sign_in_at", "last_sign_in_ip", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "updated_at"]
  end

  private

  def send_admin_analytic_event
    return unless self.current_sign_in_at_changed?

    ## event will be send if admin login only
    analytics_data = {
      identifier: self.id,
      event_name: 'admin.login.activity',
      properties: {
        current_sign_in_at: current_sign_in_at,
        last_sign_in_at: last_sign_in_at
      }
    }
    # BuilderBase::AnalyticsEvent.publish(analytics_data)
  end
end
