module BxBlockChat
  class ChatHistorySerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer

    attributes :name

    attribute :accounts_chats do |object, params|
      serializer = BxBlockChat::AccountsChatsSerializer.new(
        object.accounts_chats, {params: params}
      )
      serializer.serializable_hash[:data]
    end

    attribute :messages do |object, params|
      serializer = BxBlockChat::ChatMessageSerializer.new(
        object.messages.where.not(account_id: params[:receiver_id]), {params: params}
      )
      serializer.serializable_hash[:data]
    end
  end
end
