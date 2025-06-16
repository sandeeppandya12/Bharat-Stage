# frozen_string_literal: true

module BxBlockCategories
  class CategoryListsController < ApplicationController
    skip_before_action :validate_json_web_token

    def index
      if params[:category_name].present?
        category_name = params[:category_name]

        sub_categories = BxBlockCategories::SubCategory.joins(:category)
                          .where(categories: { name: category_name })

        if sub_categories.present?
          render json: SubCategorySerializer.new(sub_categories).serializable_hash, status: :ok
        else
          render json: { error: 'No subcategories found for this category name' }, status: :not_found
        end
      else
        @categories = BxBlockCategories::Category.includes(:sub_categories).all

        if @categories.present?
          render json: CategorySerializer.new(@categories, params: { sub_categories: true }).serializable_hash, status: :ok
        else
          render json: { message: 'No content is present' }, status: :unprocessable_entity
        end
      end
    end

  end 
end