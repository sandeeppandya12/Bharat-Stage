# frozen_string_literal: true

module BxBlockCategories
  class SubCategorySerializer < BuilderBase::BaseSerializer
    attributes :id, :name, :category_id

    attribute :sub_category_name do |object|
      object.name.titleize if object.name.present?
    end
    

    attribute :category_save_name do |object|
      object.category&.name
    end

    attribute :category_name do |object|
      object.category&.name.titleize if object.category&.name.present?
    end

    attribute :categories, if: proc { |_record, params|
      params && params[:categories] == true
    }
  end
end
