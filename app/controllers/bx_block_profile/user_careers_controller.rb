module BxBlockProfile
	class UserCareersController < ApplicationController
		include BuilderJsonWebToken::JsonWebTokenValidation
		include JSONAPI::Deserialization
	
		before_action :find_user_career, only: [:update, :destroy]

		def create
			@user_career = BxBlockProfile::UserCareer.new(
			user_career_params.merge(account_id: current_user.id)
			)

			if @user_career.save
				render json: BxBlockProfile::UserCareerSerializer.new(@user_career, serialization_options).serializable_hash,
				status: :created
			else
				render json: { errors: @user_career.errors.full_messages },
				status: :unprocessable_entity
			end
		end
  
	  def update
			if @user_career.update(user_career_params)
			  render json: BxBlockProfile::UserCareerSerializer.new(@user_career, serialization_options
				).serializable_hash.merge(meta: { message: 'User Career updated successfully' }), status: :ok

			else
			  render json: @user_career.errors, status: :unprocessable_entity
			end
	  end
  
	  def destroy
			if @user_career.destroy
			  render json: { message: 'User Career deleted successfully.' }, status: :ok
			else
			  render json: { error: 'Unable to delete the Career.' }, status: :unprocessable_entity
			end
	  end
  
	  private
  
	  def user_career_params
			params.permit(
			  :project_name, :role, :start_date, :start_year, :end_year, :end_date, :is_ongoing, :location, :description,
			  :account_id, :career_image, project_link: []
			)
		end

		def find_user_career
		  @user_career = BxBlockProfile::UserCareer.find_by(id: params[:id])
	  	if @user_career.nil?
	    	render json: { error: 'User Career not found' }, status: :not_found
	      return
	  	end
	  end

	  def serialization_options
      { params: { host: request.protocol + request.host_with_port } }
    end
	end
end