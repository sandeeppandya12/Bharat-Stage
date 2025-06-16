module BxBlockRolesPermissions
  class AccountDetailsController < ApplicationController
    # protect_from_forgery with: :exception
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :validate_json_web_token, only: [:create,:list_users,:assign_role,:get_assigned_role]
    before_action :set_account, only: [:assign_role, :get_assigned_role, :create, :list_users]
    before_action :check_admin_auth, only: [:assign_role, :create]

    def list_users
      @accounts = AccountBlock::Account.all
      if @account.present? && admin?
        render json: AccountBlock::AccountSerializer.new(@accounts).serializable_hash, status: :ok
      else
        render json: {errors: "account does not have access"}, status: :unauthorized
      end
    end

    def create
      if params[:name].present?
        role = Role.new(name: params[:name])
        if @account.present?
          if role.save
            render json: BxBlockRolesPermissions::RoleSerializer.new(role).serializable_hash, status: :created
          else
            render json: { errors: role.errors }, status: :unprocessable_entity
          end
        else
          render json: { errors: 'Account not found' }, status: :not_found
        end
      else
        render json: { errors: 'Please enter role name' }, status: :unprocessable_entity
      end
    end

    def assign_role
      return unless validate_presence_of_parameters(assign_role_params, %w[role account_id])
      role = Role.where(name: assign_role_params['role'])
      unless role.present?
        render json: { errors: 'Role does not exists' }, status: :not_found and return
      else
        @role_assigning_account = AccountBlock::Account.find_by_id(assign_role_params["account_id"])
      end
      unless @account && @role_assigning_account
        render json: { errors: 'Account not found' }, status: :not_found
      else
        @role_assigning_account.update(role_id: role[0]["id"])
        render json: BxBlockRolesPermissions::AccountRoleSerializer.new(@role_assigning_account).serializable_hash, status: :ok
      end
    end

    def get_assigned_role
      return if validates_negative_ids([params["id"]])
      @fetch_account = AccountBlock::Account.find_by_id(params["id"])
      unless @fetch_account
        render json: { errors: 'Account with this id is not found' }, status: :not_found and return
      end
      if admin_or_same_user?
        render json: BxBlockRolesPermissions::AccountRoleSerializer.new(@fetch_account).serializable_hash, status: :ok
      else
        render json: { errors: 'Account not allow to view role details' }, status: :forbidden
      end
    end

    private

    def check_admin_auth
      render json: { errors: "You are not authorized to create or assign a role." }, status: :forbidden unless admin?
    end

    def admin_or_same_user?
      admin? || (@account.id == @fetch_account.id)
    end

    def admin?
      @account.try(:role).try(:name) == "group_admin" || @account.try(:role).try(:name) == "admin"
    end

    def validates_negative_ids(ids)
      render json: { errors: 'Please provide a valid id' }, status: :unprocessable_entity if ids.any?{|value| value.to_i <= 0 }
    end

    def set_account
      @account = AccountBlock::Account.find(@token.id)
    end

    def assign_role_params
      params.require(:account_detail).permit(:role, :account_id)
    end

    def validate_presence_of_parameters(params_to_check, parameter_names)
      parameter_names.each do |parameter_name|
        unless params_to_check[parameter_name].present?
          render json: {
            errors: [params: "#{parameter_name} is not provided"]
          }, status: :unprocessable_entity and return false
        end
      end
    end
  end
end
