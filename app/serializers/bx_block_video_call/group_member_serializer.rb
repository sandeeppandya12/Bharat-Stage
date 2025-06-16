module BxBlockVideoCall
  class GroupMemberSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer
    attributes :id, :chat_id, :account_id
  end
end
