module BxBlockChat
  class MessagesController < ApplicationController
    def create
      @chat = current_user.chats.find_by_id(params[:chat_id])
      unless @chat
        return render json: {message: "Chat room is not valid or no longer exists"}, status: :not_found
      end

      message = @chat.messages.new(message_params)
      message.account_id = current_user.id
      if message.save
        message.create_activity key: "bx_block_chat_message.sendmessage_on", owner: current_user
        render json: ::BxBlockChat::ChatMessageSerializer.new(
          message,
          serialization_options
        ).serializable_hash, status: :created
      else
        render json: {errors: message.errors}, status: :unprocessable_entity
      end
    end

    private

    def message_params
      params.require(:message).permit(:message, attachments: [])
    end
  end
end
