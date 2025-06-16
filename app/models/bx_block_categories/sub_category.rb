# frozen_string_literal: true

module BxBlockCategories
  class SubCategory < BxBlockCategories::ApplicationRecord
    self.table_name = :sub_categories

    # has_and_belongs_to_many :categories, class_name: "BxBlockCategories::Category"
    belongs_to :category, class_name: 'BxBlockCategories::Category', foreign_key: 'category_id', optional: true
    enum experience_levels: { beginner: 0, intermediate: 1, expert: 2 }

     has_and_belongs_to_many :accounts, 
                          class_name: "AccountBlock::Account", 
                          join_table: "accounts_sub_categories"

# Protected Area Start
    has_and_belongs_to_many :categories, join_table: :categories_sub_categories, dependent: :destroy
    # belongs_to :parent, class_name: "BxBlockCategories::SubCategory", optional: true
    has_many :sub_categories, class_name: "BxBlockCategories::SubCategory",
      foreign_key: :parent_id, dependent: :destroy
    has_many :user_sub_categories, class_name: "BxBlockCategories::UserSubCategory",
      join_table: "user_sub_categoeries", dependent: :destroy
    # has_many :accounts, class_name: "AccountBlock::Account", through: :user_sub_categories,
    #   join_table: "user_sub_categoeries"

# Protected Area End
    validates :name, presence: true, uniqueness: { case_sensitive: false }
    # validate :check_parent_categories
    before_validation :downcase_name

    private

    def downcase_name
      self.name = name.strip
    end

    def check_parent_categories
      errors.add(:base, "Please select categories or a parent.") if categories.blank? && parent.blank?
    end
  end
end
