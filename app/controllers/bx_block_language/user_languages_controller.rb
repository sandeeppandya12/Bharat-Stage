module BxBlockLanguage
	class UserLanguagesController < ApplicationController
		def index
      if params[:search].present?
				languages = UserLanguage.where("name ILIKE ?", "#{params[:search]}%").order(:name)

      else
        languages = UserLanguage.order(:name)
      end

      render json: languages
    end
	end
end
