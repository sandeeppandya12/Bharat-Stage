# This migration comes from bx_block_video_call (originally 20220926065447)
# Protected File
class AddMeetingIdToAccountGroupsGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :account_groups_groups, :meeting_id, :string
  end
end
