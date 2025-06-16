module BxBlockChat
  class Chat < BxBlockChat::ApplicationRecord
    ActiveSupport.run_load_hooks(:chat, self)
    self.table_name = :chats

    include PublicActivity::Model
    tracked owner: proc { |controller, model| controller&.current_user }

# Protected Area Start
    has_many :accounts_chats,
      class_name: "BxBlockChat::AccountsChatsBlock",
      dependent: :destroy
# Protected Area End
    validates :name, presence: true
# Protected Area Start
    has_many :accounts, through: :accounts_chats
    has_many :messages, class_name: "BxBlockChat::ChatMessage", dependent: :destroy

# Protected Area End
    enum type: {single_user: 1, multiple_user: 2}

    def admin_accounts
      accounts_chats.where(status: :admin).includes(:accounts).pluck("accounts.id")
    end

    def last_admin?(account)
      accounts.include?(account) && accounts.count == 1
    end
  end
end
