module BxBlockProfile
  class CurrentStatusIndustry < ApplicationRecord
    self.table_name = :bx_block_profile_current_status_industries
# Protected Area Start
    belongs_to :current_status, class_name: "BxBlockProfile::CurrentStatus"
    belongs_to :industry, class_name: "BxBlockProfile::Industry"
# Protected Area End
  end
end