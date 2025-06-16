module BxBlockRolesPermissions
  class Role < ApplicationRecord
    self.table_name = :roles

# Protected Area Start
    has_many :accounts, class_name: 'AccountBlock::Account', dependent: :destroy

# Protected Area End
    OPTIONS = %w[artist film_maker]
    enum name: { group_admin: '0', group_basic: '1', admin: '2', basic: '3'}
    validates :name, uniqueness: { message: 'Role already present' }
    
    # validates_uniqueness_of :name
    validate do
      if @not_valid_name
        errors.add(:name, "Not valid name, please select from the list: #{(OPTIONS * ',')}")
      end
    end
    def name=(value)
    if !OPTIONS.include?(value)
        @not_valid_name = true
      else
        super value
      end
    end
  end
end
