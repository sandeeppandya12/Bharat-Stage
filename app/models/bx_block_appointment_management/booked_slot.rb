module BxBlockAppointmentManagement
  class BookedSlot < ApplicationRecord
    self.table_name = :bx_block_appointment_management_booked_slots

# Protected Area Start
    belongs_to :service_provider, class_name: "AccountBlock::Account"
# Protected Area End
  end
end
