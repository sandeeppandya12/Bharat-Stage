# frozen_string_literal: true

module BxBlockCategories
  class Category < BxBlockCategories::ApplicationRecord
    include ActiveStorageSupport::SupportForBase64
    self.table_name = :categories

    # has_and_belongs_to_many :accounts, class_name: "AccountBlock::Account"
    # has_and_belongs_to_many :accounts, class_name: "AccountBlock::Account", join_table: :accounts_categories
    has_and_belongs_to_many :accounts,
                          join_table: 'accounts_categories',
                          class_name: 'AccountBlock::Account'
    # has_and_belongs_to_many :sub_categories, class_name: "BxBlockCategories::SubCategory"

    validates :name, presence: true, uniqueness: true

# Protected Area Start
    has_one_base64_attached :light_icon
    has_one_base64_attached :light_icon_active
    has_one_base64_attached :light_icon_inactive
    has_one_base64_attached :dark_icon
    has_one_base64_attached :dark_icon_active
    has_one_base64_attached :dark_icon_inactive

    has_and_belongs_to_many :sub_categories,
      join_table: :categories_sub_categories,
      foreign_key: :category_id,
      dependent: :destroy

    has_many :ctas, class_name: "BxBlockCategories::Cta", dependent: :nullify

    has_many :user_categories, class_name: "BxBlockCategories::UserCategory",
      join_table: "user_categoeries", dependent: :destroy
    # has_many :accounts, class_name: "AccountBlock::Account", through: :user_categories,
    #   join_table: "user_categoeries"

# Protected Area End
    validates :name, presence: true, uniqueness: { case_sensitive: false }
    # validates_uniqueness_of :identifier, allow_blank: true

    enum identifier: %w[k12 higher_education govt_job competitive_exams upskilling]

    before_destroy :nullify_sub_category_reference
    before_validation :downcase_name

    private

    def downcase_name
      if name.present?
        self.name = name.strip
      end
    end

    def nullify_sub_category_reference
      BxBlockCategories::SubCategory.where(category_id: id).update_all(category_id: nil)
    end
  end
end
