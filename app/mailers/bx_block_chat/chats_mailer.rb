module BxBlockChat
  class ChatsMailer < ApplicationMailer
    def new_message
      @to = params[:to]
      @chat_name = params[:chat]
      mail(to: @to, user: @user, subject: "New message")
    end
  end
end
