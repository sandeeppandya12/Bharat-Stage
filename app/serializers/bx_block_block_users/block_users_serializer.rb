module BxBlockBlockUsers
  class BlockUsersSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer
    attributes *[
      :current_user_id,
      :account_id,
      :created_at,
      :updated_at,
      :account
    ]
  end
end
