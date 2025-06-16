module BxBlockChat
  class ChatsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation
    before_action :validate_json_web_token
    before_action :set_account
    before_action :find_chat, only: [:read_messages]

    def index
      user_chats = @current_user.chats
      if user_chats.present?
        render json: { user_chat: user_chats}, status: :ok
      else
        render json: { user_chats: "not found"}, status: :unprocessable_entity
      end
    end

    def show
      chat = BxBlockChat::Chat.includes(:accounts).find(params[:id])
      render json: ::BxBlockChat::ChatSerializer.new(chat, serialization_options).serializable_hash, status: :ok
    end

    def mychats
      chat_ids = AccountBlock::Account.find(current_user.id).chats.pluck(:id)
      chats = current_user.chats.where(id: chat_ids)
      params[:receiver_id] = current_user.id
      render json: ::BxBlockChat::ChatMyChatSerializer.new(chats, chat_message_serialization_options).serializable_hash, status: :ok
    end

    def create
      chat = BxBlockChat::Chat.new(chat_params)
      chat.chat_type = "multiple_user"
      if chat.save
        BxBlockChat::AccountsChatsBlock.create(account_id: current_user.id,
          chat_id: chat.id,
          status: :admin)
        render json: ::BxBlockChat::ChatSerializer.new(chat, serialization_options).serializable_hash, status: :created
      else
        render json: {errors: chat.errors}, status: :unprocessable_entity
      end
    end

    def history
      chat_ids = AccountBlock::Account.find(params[:receiver_id]).chats.pluck(:id)
      chats = current_user.chats.where(id: chat_ids)
      if chats.present?
        render json: ::BxBlockChat::ChatHistorySerializer.new(chats, chat_message_serialization_options).serializable_hash, status: :ok
      else
        render json: {message: "They don't have any chat history"}, status: :unprocessable_entity
      end
    end

    def send_message
      sender_uid = @current_user&.comet_chat_uid
      receiver_uid = params[:receiver_uid] if params[:receiver_uid].present?
      message = params[:message] if params[:message].present?
      media_file = params[:media_file]

      if sender_uid.blank? || receiver_uid.blank? || message.blank?
        render json: { error: "Sender, Receiver IDs and message are required" }, status: :bad_request
        return
      end

      if sender_uid == receiver_uid
        return render json: { error: "You cannot send a message to your own account. Please choose a different recipient."  }, status: :bad_request
      end

      if media_file.present?
        size_in_mb   = media_file.size.to_f / (1024 * 1024)
        content_type = media_file.content_type

        if size_in_mb > 10
          return render json: { error: "Image size should not exceed 10MB." }, status: :bad_request
        end
      end

      response = BxBlockCometchatintegration::ChatService.send_message(sender_uid,receiver_uid, message, media_file)
      account = AccountBlock::Account.find_by(comet_chat_uid: receiver_uid)
      if account&.setting&.in_app_notification?
        BxBlockNotifications::Notification.create(
          account_id: receiver_uid,     
          chat_notification: true,
          read_at: DateTime.now,
          contents: "#{message}",
          title: "#{@current_user.first_name} #{@current_user.last_name} sent you a message."
        )
      end
      render json: { data:JSON.parse(response.body) }
    end

    def get_user_conversation
      on_behalf_of_id = params[:on_behalf_of_id]
      response = BxBlockCometchatintegration::ChatService.get_user_conversation(on_behalf_of_id)
      render json: { data:JSON.parse(response.body) }
    end

    def mark_as_delivered
      sender_uid = @current_user.comet_chat_uid
      receiver_uid = params[:receiver_uid]
      response = BxBlockCometchatintegration::ChatService.mark_as_delivered(sender_uid,receiver_uid)
      render json: { data:JSON.parse(response.body) }
    end
     
    def mark_as_read
      sender_uid = @current_user.comet_chat_uid
      receiver_uid = params[:receiver_uid]
      response = BxBlockCometchatintegration::ChatService.mark_as_read(sender_uid,receiver_uid)
      render json: { data:JSON.parse(response.body) }
    end

    def block_user
      sender_uid = @current_user.comet_chat_uid
      receiver_uid = params[:receiver_uid]
      response = BxBlockCometchatintegration::ChatService.block_user(sender_uid,receiver_uid)
      render json: { data:JSON.parse(response.body) }
    end

    def unblock_user
      sender_uid = @current_user.comet_chat_uid
      receiver_uid = params[:receiver_uid]
      response = BxBlockCometchatintegration::ChatService.unblock_user(sender_uid,receiver_uid)
      render json: { data:JSON.parse(response.body) }
    end

    def delete_message
      sender_uid = @current_user.comet_chat_uid
      message_id = params[:message_id]
      response = BxBlockCometchatintegration::ChatService.delete_message(message_id, sender_uid)
      render json: { data:JSON.parse(response.body) }
    end

    def search_conversations
      search_query = params[:search_query]
      sender_uid = @current_user.comet_chat_uid

      if search_query.blank? || sender_uid.blank?
        render json: { error: "Search query are required" }, status: :bad_request
        return
      end
      response = BxBlockCometchatintegration::ChatService.fetch_conversations(sender_uid, search_query)
      if response.code.to_i == 200
         conversations = JSON.parse(response.body)["data"] || []

        if search_query.present?
          filtered_conversations = conversations.select do |conversation|
            conversation["conversationWith"]["name"].downcase.include?(search_query.downcase)
          end
          return render json: { data:filtered_conversations }
        else
          return conversations
        end
      else
        raise "Error fetching conversations: #{response.message}"
      end
    end

    def chat_history
      on_behalf_of_id = @current_user.comet_chat_uid
      response = BxBlockCometchatintegration::ChatService.get_all_chat(on_behalf_of_id)
      render json: { data:JSON.parse(response.body) }
    end

    def delete_conversation
      conversation_id = params[:conversation_id]

      if conversation_id.blank?
        render json: { error: "conversations id are required" }, status: :bad_request
        return
      end

      response = BxBlockCometchatintegration::ChatService.delete_user_conversation(conversation_id)
      render json: {data: JSON.parse(response.body)}
    end

    def read_messages
      @chat.messages.each do |chatdata|
        unless chatdata.read_by.include?(current_user.id)
          read_by_array = chatdata.read_by << current_user.id
          chatdata.update(is_mark_read: true, read_by: read_by_array)
        end
      end
      @chat.create_activity(key: "bx_block_chat.readmessage_on", owner: current_user)
      render json: ::BxBlockChat::ChatSerializer.new(@chat, serialization_options).serializable_hash, status: :ok
    rescue => e
      render json: {error: e}
    end

    def update
      chat = Chat.find(params[:id])
      if !params[:chat][:name].nil?
        Chat.where(id: chat.id).update(name: params[:chat][:name])
        current_user.accounts_chats.find_by(chat_id: chat.id)&.update(muted: params[:chat][:muted])
      end
      if !params[:chat][:muted].nil?
        current_user.accounts_chats.where(chat_id: chat.id).first.update(muted: params[:chat][:muted])
      end
      chat.reload
      if chat.present?
        render json: ::BxBlockChat::ChatSerializer.new(
          chat, serialization_options
        ).serializable_hash, status: :ok
      else
        render json: {errors: format_activerecord_errors(chat.errors)},
          status: :unprocessable_entity
      end
    end

    def search
      @chats = current_user
        .chats
        .where("name ILIKE :search", search: "%#{search_params[:query]}%")
      render json: ChatSerializer.new(@chats, serialization_options).serializable_hash, status: :ok
    end

    def search_messages
      @messages = ChatMessage
        .where(chat_id: current_user.chat_ids)
        .where("message ILIKE :search", search: "%#{search_params[:query]}%")
      render json: ChatMessageSerializer.new(@messages, serialization_options).serializable_hash, status: :ok
    end

    private

    def chat_params
      params.require(:chat).permit(:name)
    end

    def set_account
      @current_user = AccountBlock::Account.find_by(id: @token.id)
      if @current_user.nil?
        render json: { success: false, message: "Account not found." }, status: :not_found
        return
      end
    end

    def search_params
      params.permit(:query)
    end

    def find_chat
      @chat = Chat.find_by_id(params[:chat_id])
      if @chat.nil?
        render json: {message: "Chat room is not valid or no longer exists"}, status: :not_found
      end
    end
  end
end
