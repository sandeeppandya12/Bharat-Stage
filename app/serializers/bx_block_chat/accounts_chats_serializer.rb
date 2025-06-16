module BxBlockChat
  class AccountsChatsSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer

    attributes :account_id, :muted

    attribute :unread_count do |object, params|
      object.chat.messages.count.to_i - object.chat.messages.where("#{object.account_id} = ANY (read_by)").count.to_i
    end
  end
end
