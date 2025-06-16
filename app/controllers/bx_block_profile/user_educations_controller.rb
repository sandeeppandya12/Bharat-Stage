module BxBlockProfile
  class UserEducationsController < ApplicationController
    before_action :find_user_education, only: [:update, :destroy]

    def create
      @user_education = BxBlockProfile::UserEducation.new(
        user_educations_params.merge(account_id: current_user.id)
      )

      if @user_education.save
        render json: BxBlockProfile::UserEducationSerializer.new(@user_education).serializable_hash,
               status: :created
      else
        render json: { errors: @user_education.errors.full_messages },
               status: :unprocessable_entity
      end
    end
  
    def update
      if @user_education.update(user_educations_params)
        render json: BxBlockProfile::UserEducationSerializer.new(@user_education, message: 'User Career updated successfully').serializable_hash,
               status: :ok
      else
        render json: { errors: @user_education.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      if @user_education.destroy
        render json: { message: 'Education deleted successfully.' }, status: :ok
      else
        render json: { error: 'Unable to delete the Education.' }, status: :unprocessable_entity
      end
    end

    private

    def user_educations_params
      params.permit(:experience_level, :institute_name, :start_year, :end_year, :qualification, :start_date, :end_date, :is_ongoing, :location, :account_id)
    end

    def find_user_education
      @user_education = BxBlockProfile::UserEducation.find_by(id: params[:id])
      if @user_education.nil?
        render json: { error: 'User Education not found' }, status: :not_found
        return
      end
    end
  end
end
  