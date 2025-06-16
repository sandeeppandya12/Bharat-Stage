# frozen_string_literal: true

module BxBlockCategories
  class UserSubCategory < ApplicationRecord
    self.table_name = :user_sub_categories

# Protected Area Start
    belongs_to :account, class_name: "AccountBlock::Account"
    belongs_to :sub_category
# Protected Area End
  end
end
