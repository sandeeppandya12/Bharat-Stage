module BxBlockSubscriptions
  module PatchAccountChatsAssociations
    extend ActiveSupport::Concern

    included do
      has_many :accounts_chats, class_name: "BxBlockChat::AccountsChatsBlock"
      has_many :chats, through: :accounts_chats
    end
  end
end
