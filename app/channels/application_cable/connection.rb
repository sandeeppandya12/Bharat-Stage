module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.headers[:token] || request.params[:token]
      if (verified_user = ::AccountBlock::Account.find_by(id: ::BuilderJsonWebToken.decode(token).id))
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
