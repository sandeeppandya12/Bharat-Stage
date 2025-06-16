module CheckCurrentUser
  private

  def current_user
    @current_user ||= AccountBlock::Account.find(@token.id)
  rescue ActiveRecord::RecordNotFound => e
    render json: {errors: [
      {message: "Please login again."}
    ]}, status: :unprocessable_entity
  end
end
