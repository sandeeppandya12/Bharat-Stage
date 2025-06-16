module BxBlockEmergency
  class Emergency < ApplicationRecord
    ActiveSupport.run_load_hooks(:emergency, self)

    self.inheritance_column = :_type_disabled
    self.table_name = :bx_block_emergency_emergencies
    enum type: %i[sos lor]
    default_scope { where(is_active: true) }
    validates  :name, :type, :phone_number, :created_by, presence: true
    validates  :phone_number, length: { is: 10 }
  end
end
