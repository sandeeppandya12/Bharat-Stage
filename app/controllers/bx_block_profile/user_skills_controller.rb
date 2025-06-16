module BxBlockProfile
    class UserSkillsController < ApplicationController
      def create
        @user_skill = BxBlockProfile::UserSkill.new(
          user_skills_params.merge(account_id: current_user.id)
        )
  
        if @user_skill.save
          render json: BxBlockProfile::UserSkillSerializer.new(@user_skill).serializable_hash,
                 status: :created
        else
          render json: { errors: @user_skill.errors.full_messages },
                 status: :unprocessable_entity
        end
      end
  
      def destroy
        @user_skill = BxBlockProfile::UserSkill.find_by(id: params[:id])
  
        if @user_skill.nil?
          render json: { error: 'No Skill Found' }, status: :not_found
          return
        end
  
        if @user_skill.destroy
          render json: { message: 'Skill deleted successfully.' }, status: :ok
        else
          render json: { error: 'Unable to delete the Skill.' }, status: :unprocessable_entity
        end
      end
  
      private
  
      def user_skills_params
        params.permit(:experience_level)
      end
    end
  end
  