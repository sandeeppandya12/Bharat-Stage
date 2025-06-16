module BxBlockTermsAndConditions
  class TermsAndConditionsController < ApplicationController
    skip_before_action :validate_json_web_token, only: [:index, :privacy_policy, :about_us]
  
    def create
      term = BxBlockTermsAndConditions::TermsAndCondition.new(terms_and_condition_params
        .merge(account_id: current_user.id))
      if term.save
        render json: {data: {id: term.id}}, status: :created
      else
        render json: {errors: term.errors}, status: :unprocessable_entity
      end
    end

    def index
      terms = BxBlockTermsAndConditions::TermsAndCondition.all.select(:id, :title, :description, :created_at)
      if terms.present?
        render json: {data: terms}, status: :ok
      else
        render json: {message: "terms and conditions data not found"}, status: :not_found
      end
    end

    def privacy_policy
      privacy_policies = BxBlockTermsAndConditions::PrivacyPolicy.all
      if privacy_policies.present?
        render json: {data: privacy_policies}, status: :ok
      else
        render json: {message: "privacy and policy data not found"}, status: :not_found
      end
    end

    def about_us
      about_us = BxBlockTermsAndConditions::AboutUs.all
      if about_us.present?
        render json: {data: about_us}, status: :ok
      else
        render json: {message: "about us data not found"}, status: :not_found
      end
    end

    def show
      if invalid_id?(params[:id].to_i)
        render json: {message: "Please provide valid id"}, status: :unprocessable_entity
      else
        term = BxBlockTermsAndConditions::TermsAndCondition.find(params[:id])
        if term.present?
          render json: TermsAndConditionsSerializer.new(term)
            .serializable_hash, status: :ok
        else
          render json: {message: "terms and conditions data not found"}, status: :not_found
        end
      end
    end

    def latest_record
      term = BxBlockTermsAndConditions::TermsAndCondition.last

      if term.present?
        user_term = BxBlockTermsAndConditions::UserTermAndCondition.find_by(terms_and_condition_id: term.id, account_id: current_user.id)
        is_accepted = if user_term.present?
                        user_term.is_accepted
                      else
                        false
                      end
        render json: { id: term.id, is_accepted: is_accepted, description: term.description }, status: :ok
      else
        render json: {message: "terms and conditions data not found"}, status: :not_found
      end
    end

    def accept_and_reject
      id = params[:terms_and_condition_id]
      if invalid_id?(id.to_i)
        render json: {message: "Please provide valid id"}, status: :unprocessable_entity
      else
        term = BxBlockTermsAndConditions::TermsAndCondition.find(id)
        if term.present?
          user_term = BxBlockTermsAndConditions::UserTermAndCondition.find_by(terms_and_condition_id: term.id, account_id: current_user.id)
          if params[:is_accepted] == true || params[:is_accepted] == false
            if user_term.present?
              user_term.update!(is_accepted: params[:is_accepted])
            else
              user_term = BxBlockTermsAndConditions::UserTermAndCondition.create!(terms_and_condition_id: term.id, account_id: current_user.id, is_accepted: params[:is_accepted])
            end
            render json: {terms_and_condition_id: term.id, is_accepted: user_term.is_accepted, account_id: current_user.id}, status: :created
          else
            render json: {message: "is_accepted should be either true or false."}, status: :unprocessable_entity
          end
        else
          render json: {message: "terms and conditions data not found"}, status: :not_found
        end
      end
    end

    private

    def check_admin
      if admin_auth.eql?("true") || account_auth.eql?("true")
        true
      else
        render json: {message: "You are not authorised user or proper role admin"}, status: :unauthorized
      end
    end

    def check_basic
      if basic_auth.eql?("true") || account_auth.eql?("true")
        true
      else
        render json: {message: "You are not authorised user or proper role basic"}, status: :unauthorized
      end
    end

    def invalid_id?(id)
      id <= 0 || !id.present? ? true : false
    end

    def terms_and_condition_params
      params.require(:terms_and_condition).permit(:description)
    end
  end
end
