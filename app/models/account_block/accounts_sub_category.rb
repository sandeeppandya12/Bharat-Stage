module AccountBlock
  class AccountsSubCategory < ApplicationRecord
    self.table_name = 'accounts_sub_categories'
    # self.primary_key = :account_id, :sub_category_id


    belongs_to :account, class_name: "AccountBlock::Account"
    belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory"

    enum experience_level: { beginner: 0, intermediate: 1, expert: 2 }
  end
end
