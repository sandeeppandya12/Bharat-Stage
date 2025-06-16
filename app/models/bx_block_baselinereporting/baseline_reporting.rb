module BxBlockBaselinereporting
  class BaselineReporting < ApplicationRecord
  	self.table_name = :bx_block_baselinereporting_baseline_reportings
  	validates :sos_time, presence: true
  end
end
