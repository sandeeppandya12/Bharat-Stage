# frozen_string_literal: true

module BxBlockCustomAds
  class AdvertisementsController < BxBlockCustomAds::ApplicationController
    before_action :set_ad, only: %i[show destroy update approve reject authorized?]

    def index
      advertisements = case params[:scope]
                       when 'pending'
                          Advertisement.pending
                       when 'rejected'
                          Advertisement.rejected
                       else
                          Advertisement.approved
                       end
      render json: {
        advertisements: advertisements,
        message: 'Successfully loaded'
      }
    end

    def create
      advertisement = Advertisement.new(advertisement_params)
      seller_account = BxBlockCustomForm::SellerAccount.find_by( account_id: current_user.id)
      if !seller_account
        render json: {
          message: 'Seller Account is not Available.'
        }, status: :not_found
      else
        advertisement.seller_account_id = seller_account.id
        if advertisement.save
          render json: {
            advertisement: advertisement,
            message: 'Successfully created'
          }, status: :created
        else
          render json: {
            errors: advertisement.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end

    def show
      render json: {
        advertisement: @ad,
        message: 'Successfully loaded'
      }
    end

    def update
      if params.dig(:advertisement, :status).present?
        status_update_by_admin
      elsif authorized?
        if @ad.update(advertisement_params)
          render json: @ad, message: 'Updated successfully', status: :ok
        else
          render json: @ad.errors.full_messages, status: :bad_request
        end
      else
        render json: { error: [message: 'You can not update the status of an advertisement'] },
        status: :unauthorized
      end
    end

    def destroy
      if admin?
        render json: { message: 'Adverstisement Deleted successfully' }, status: :ok if @ad.destroy
      else
        render json: { error: [message: 'You can not delete this advertisement'] },
              status: :unauthorized
      end
    end

    def approve
      if admin? && (@ad.pending? || @ad.rejected?)
        @ad.approved!
        render json: @ad, message: 'Advertisement has been Approved Successfully.', status: :ok
      elsif !admin?
        render json: { error: [message: 'You can not Approve this advertisement'] },
              status: :unauthorized
      else
        render json: { error: [message: 'Advertisement has already been Approved.'] },
              status: :unprocessable_entity
      end
    end

    def reject
      if admin? && (@ad.approved? || @ad.pending?)
        @ad.rejected!
        render json: @ad, message: 'Advertisement has been Rejected Successfully.', status: :ok
      elsif !admin?
        render json: { error: [message: 'You can not Reject this Advertisement'] },
              status: :unauthorized
      else
        render json: { error: [message: 'Advertisement has already been Rejected.'] },
              status: :unprocessable_entity
      end
    end

    def authorized?
      @ad.seller_account.account_id == current_user.id || admin?
    end

    def status_update_by_admin
      if admin?
        if @ad.update(advertisement_params)
          render json: @ad, message: 'Updated successfully', status: :ok
        else
            render json: @ad.errors.full_messages, status: :bad_request
        end
      else
        render json: { message: "You can't update the status of an advertisement." },
        status: :unauthorized
      end
    end

    private

    def advertisement_params
      params.require(:advertisement).permit(
        :name, :description, :duration, :advertisement_for, :status, :banner
      )
    end

    def set_ad
      @ad = Advertisement.find_by_id(params[:id])
      return render json: { message: 'Record not found' }, status: 404 unless @ad
    end

    def admin?
      BxBlockRolesPermissions::Role.find_by_id(current_user.role_id).name == 'admin' if current_user.role_id.present?
    end
  end
end
