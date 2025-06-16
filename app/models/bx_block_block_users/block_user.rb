module BxBlockBlockUsers
  class BlockUser < BxBlockBlockUsers::ApplicationRecord
    self.table_name = :block_users
# Protected Area Start
    belongs_to :account, class_name: 'AccountBlock::Account'
    belongs_to :current_user, class_name: 'AccountBlock::Account'
# Protected Area End
  end
end
