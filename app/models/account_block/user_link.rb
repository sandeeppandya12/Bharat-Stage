module AccountBlock
  class UserLink < AccountBlock::ApplicationRecord
    ActiveSupport.run_load_hooks(:account, self)
    self.table_name = :user_links

    belongs_to :account

    validates :key, presence: true, uniqueness: { scope: :account_id }
    validates :value, presence: true
  end
end
 