module BxBlockProfile
	class UserProfilesController < ApplicationController
		skip_before_action :validate_json_web_token, only: [:index]  # Skipping token validation for index action
		before_action :fetch_artist_profiles, only: [:index]

	  def create
			@user_profile = BxBlockProfile::ArtistProfile.new(
				user_profile_params.merge(account_id: current_user.id)
			)
	
			if @user_profile.save
				render json: BxBlockProfile::UserProfileSerializer.new(@user_profile).serializable_hash,
					status: :created
			else
				render json: { errors: @user_profile.errors.full_messages },
					status: :unprocessable_entity
			end
	  end

	  def index
			if @artist_profiles.present?
				render json: UserProfileSerializer.new(@artist_profiles).serializable_hash, status: :ok
			else
				render json: {errors: "profiles does not exist"}, status: :not_found
			end
	  end
  
	  def update
		@user_profile = BxBlockProfile::ArtistProfile.find_by(id: params[:id])
  
		if @user_profile.nil?
		  render json: { error: 'Artist Profile not found' }, status: :not_found
		  return
		end
  
		if @user_profile.update(user_profile_params)
		  render json: { message: 'Artist Profile updated successfully' }, status: :ok
		else
		  render json: @user_profile.errors, status: :unprocessable_entity
		end
	  end
  
	  private

		def fetch_artist_profiles
			return render json: { error: "Please enter at least 3 characters for search" }, status: :bad_request if params[:name].present? && params[:name].length < 3
			@artist_profiles = params[:name].present? ? ArtistProfile.search_by_name(params[:name]) : ArtistProfile.all
		  apply_sorting
		end

		def apply_sorting
			case params[:sort_by]
			when "name(A-Z)"
				@artist_profiles = @artist_profiles.order(Arel.sql("first_name ASC"))
			when "name(Z-A)"
				@artist_profiles = @artist_profiles.order(Arel.sql("first_name DESC"))
			when "experience(Expert-Beginner)"
        @artist_profiles = @artist_profiles.order(Arel.sql("
				CASE experience_level
					WHEN 'Expert' THEN 1
					WHEN 'Advanced' THEN 2
					WHEN 'Intermediate' THEN 3
					WHEN 'Beginner' THEN 4
					ELSE 5
				END ASC
			"))
			when "experience(Beginner-Expert)"
				@artist_profiles = @artist_profiles.order(Arel.sql("
				CASE experience_level
					WHEN 'Beginner' THEN 1
					WHEN 'Intermediate' THEN 2
					WHEN 'Advanced' THEN 3
					WHEN 'Expert' THEN 4
					ELSE 5
				END ASC
			"))
			end
		end		

	  def user_profile_params
		params.permit(
		  :first_name, :last_name, :description, :height, :weight, :location, :gender, :age,
		  :role, :experience_level, :account_id, :profile_picture, :cover_photo,
		  languages: [], portfolio_links: [], social_media_links: []
		)
	  end
	end
  end
  