module BxBlockChat
  class ChatMyChatSerializer < BuilderBase::BaseSerializer
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
        object.messages.last, {params: params}
      )
      serializer.serializable_hash[:data]
    end
  end
end
