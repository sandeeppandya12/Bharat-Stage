# This migration comes from bx_block_baselinereporting (originally 20230531103216)
class CreateBxBlockBaselinereportingBaselineReportings < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_baselinereporting_baseline_reportings do |t|
      t.string :sos_time

      t.timestamps
    end
  end
end
