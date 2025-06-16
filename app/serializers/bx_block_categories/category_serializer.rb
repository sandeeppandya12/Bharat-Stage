# frozen_string_literal: true

module BxBlockCategories
  class CategorySerializer < BuilderBase::BaseSerializer
    attributes :id, :name
    # attribute :sub_categories, if: proc { |_record, params|
    #   params && params[:sub_categories] == true
    # }

    # attribute :selected_sub_categories do |object, params|
    #   object.sub_categories.where(id: params[:selected_sub_categories]) if params[:selected_sub_categories].present?
    # end
    attribute :category_name do |object|
      object.name.titleize if object.name.present?
    end
    
  end
end
