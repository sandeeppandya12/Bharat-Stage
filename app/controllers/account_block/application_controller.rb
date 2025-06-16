module AccountBlock
  class ApplicationController < BuilderBase::ApplicationController
    # protect_from_forgery with: :exception
    private
    
    def format_activerecord_errors(errors)
      errors.each_with_object([]) { |(attr, err), result| result << {attr => err} }
    end
  end
end
