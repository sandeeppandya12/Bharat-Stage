# frozen_string_literal: true

module BxBlockCustomAds
  class Advertisement < ApplicationRecord
    self.table_name = :advertisements
# Protected Area Start
    belongs_to :seller_account, class_name: 'BxBlockCustomForm::SellerAccount'
    belongs_to :role, class_name: 'BxBlockRolesPermissions::Role', required: false

# Protected Area End
    enum status: %i[pending approved rejected]
    enum advertisement_for: %i[seller user]

    validates :name, presence: true, uniqueness: {
      scope: :seller_account,
      case_sensitive: false,
      message: 'You can not create ads with duplicate names, please try a different name'
    }

    validates :status,
              inclusion: { in: statuses.keys,
              message: ":Please select options from the list [ #{statuses.keys * ','} ]"}

    validates :advertisement_for, inclusion: { in: advertisement_fors.keys,
              message: ":Please select options from the list [ #{advertisement_fors.keys * ','} ]"}

# Protected Area Start
    has_one_attached :banner

# Protected Area End
    before_create :add_status

    after_create :notify_admin

    ROLE_ADMIN = 'admin'
    ROLE_BASIC = 'basic'

    def add_status
      self.status = 0
    end

    def notify_admin
      # AdvertisementMailer.notify_admin(advertisement:self).deliver
    end
  end
end
