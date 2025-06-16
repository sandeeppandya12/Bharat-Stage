# This migration comes from bx_block_emergency (originally 20230421112901)
class CreateBxBlockEmergencyEmergencies < ActiveRecord::Migration[6.0]
  def change
    create_table :bx_block_emergency_emergencies do |t|
      t.string :name, null: false
      t.text :description
      t.integer :type, null: false
      t.string :phone_number, null: false
      t.string :created_by, null: false
      t.string :updated_by, null: true
      t.boolean :is_active, default: true, null: false
      t.timestamps
    end
  end
end
