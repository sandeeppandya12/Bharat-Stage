# frozen_string_literal: true

module BxBlockAdvancedSearch
  class SearchController < ApplicationController
    skip_before_action :validate_json_web_token, only: [:filter]

    def filter
      unless params[:first_name].present? || params[:last_name].present?
        return render json: {errors: ["Parameters are not correct"]},
          status: :unprocessable_entity
      end

      accounts =
        BxBlockAdvancedSearch::AdvancedSearch.search(
          first_name: params[:first_name],
          last_name: params[:last_name]
        )

      if accounts.present?
        render json: {accounts: BxBlockAdvancedSearch::AccountSearchSerializer.new(
          accounts
        ).serializable_hash}, status: :ok
      else
        render json: {accounts: "No account found with those associated first name and last name"}, status: :ok
      end
    end
  end
end
