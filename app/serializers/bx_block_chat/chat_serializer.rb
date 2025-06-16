module BxBlockChat
  class ChatSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer

    attributes :id, :name

    has_many :accounts, serializer: ::AccountBlock::AccountSerializer
    attribute :accounts_chats do |object, params|
      serializer = BxBlockChat::AccountsChatsSerializer.new(
        object.accounts_chats, {params: params}
      )
      serializer.serializable_hash[:data]
    end

    attribute :messages do |object, params|
      serializer = BxBlockChat::ChatMessageSerializer.new(
        object.messages, {params: params}
      )
      serializer.serializable_hash[:data]
    end
  end
end
