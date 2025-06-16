# This migration comes from bx_block_content_management (originally 20230419120851)
class AddPublishDateIntoContentManagementContentManagements < ActiveRecord::Migration[6.0]
  def change
    add_column :bx_block_content_management_content_managments, :publish_date, :datetime
  end
end
