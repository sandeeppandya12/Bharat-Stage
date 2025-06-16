require 'csv'
module BxBlockChatbackuprestore
    class ChatBackupRestoresController< ApplicationController
      include BuilderJsonWebToken::JsonWebTokenValidation
      before_action :validate_json_web_token 
      ROOMERROR = "Room id not present"
      ROOMERROR1 = "Room does not exist, invalid room id"

      def chat_backup
        chat_rooms = BxBlockChatbackuprestore::ChatRoom.includes(:chat_messages).where("account_id = ? or chat_user = ?", current_user.id , current_user.id)
        data = []
        chat_rooms.each do |chat_room|
          room_data = []
          room_data << "Chat Room Details:"
          room_data << "ID: #{chat_room.id}"
          room_data << "ID: #{chat_room.account_id}"
          room_data << "ID: #{chat_room.chat_user}"
          room_data << "\nChat Messages:" 

          chat_room.chat_messages.each do |message|
            room_data << "Message ID: #{message.id}"
            room_data << "Content: #{message.message}"
            room_data << "ChatRoom ID: #{message.chat_room_id}"
            room_data << "Timestamp: #{message.created_at}"
            room_data << "---"
          end
          room_data << "========================================="
          data << room_data.join("\n")
        end
        file_path = Rails.root.join('tmp', 'chat_rooms_data1.txt')

        File.open(file_path, 'w') do |file|
          file.write(data.join("\n"))
        end
        send_file(file_path, filename: 'chat_rooms_data1.txt', type: 'text/plain')
      end
      
      def participant_list
        accounts = AccountBlock::Account.where(role_id: BxBlockRolesPermissions::Role.find_by(name: "employee").id).last(40).reverse
        @total_count = accounts.count
        
        if params[:page].present? && params[:limit].present?
          page = params[:page].to_i
          limit = params[:limit].to_i
          offset = page * limit
          accounts = accounts.slice(offset, limit)
        end
        render json: {
          data: accounts.map { |obj| { id: obj.id, full_name: obj.first_name || obj.full_name || obj.email } },
          count: @total_count
        }
      end
      
      def chat_request
        if params[:participant_user_id].present?
          participant = AccountBlock::Account.where(id: params[:participant_user_id]).last
          return render json: {error: "you cannot create room with you self"},status: :unprocessable_entity if current_user.id == participant.id
          return render json: {error: "invalid participant/ participant does not exist"},status: :unprocessable_entity if participant.nil?
          if BxBlockChatbackuprestore::ChatRoom.where(account_id: current_user.id ,chat_user: participant.id).last.present?
            chat_room = BxBlockChatbackuprestore::ChatRoom.where(account_id: current_user.id ,chat_user: participant.id).last
          else
            chat_room = BxBlockChatbackuprestore::ChatRoom.where(account_id: participant.id ,chat_user: current_user.id).last
          end
          if chat_room.nil?
            chat_room = BxBlockChatbackuprestore::ChatRoom.create(account_id: current_user.id ,chat_user: participant.id) 
            return render json: {data: {room_id: chat_room.id,current_user: chat_room.account_id , requested_user: chat_room.chat_user} }, status: :created
          end
          return render json: {data: {room_id: chat_room.id,current_user: chat_room.account_id , requested_user: chat_room.chat_user }}, status: :ok
        else
          return render json: {error: "participant user id not present"},status: :unprocessable_entity
        end
      end
      
      def active_chats_room
        data = []
        active_rooms = BxBlockChatbackuprestore::ChatRoom.where(chat_user: current_user.id)
        if active_rooms.blank?
          active_rooms = BxBlockChatbackuprestore::ChatRoom.where(account_id: current_user.id)
        end
        if active_rooms.present?
          active_rooms.map do|obj|
            data << {room_id: obj.id ,account_id: obj.account_id , chat_user: obj.chat_user}
          end
          return render json:  {data: data}, status: :ok
        else
          return render json: {message: "No active chat rooms"}, status: :ok 
        end
      end
      
      def creating_chat_message
        if params[:room_id].present? && params[:message].present?
          room = BxBlockChatbackuprestore::ChatRoom.where(id: params[:room_id]).last
          return render json: {error: ROOMERROR1 },status: :unprocessable_entity if room.nil?
          chat_message = BxBlockChatbackuprestore::ChatMessage.create(account_id: current_user.id, chat_room_id: room.id, message: params[:message])
          return render json: {room_id: room.id, account_id: chat_message.account_id , message: chat_message.message ,created_at: chat_message.created_at}, status: :created 
        else
          return render json: {error: ROOMERROR},status: :unprocessable_entity
        end
      end
  
      def all_chat_message
        data = []
        if params[:room_id].present?
          room = BxBlockChatbackuprestore::ChatRoom.where(id: params[:room_id]).last
          return render json: {error: ROOMERROR1},status: :unprocessable_entity if room.nil?
          if current_user.id == room.account_id || current_user.id == room.chat_user
            all_messages = BxBlockChatbackuprestore::ChatMessage.where(chat_room_id: room.id).reverse_order
            all_messages.map do|obj|
              data << {id: obj.id ,account: obj.account_id, message: obj.message , created_at: obj.created_at}
            end
            if data.blank?
              return render json: {message: "No chat in this room"},status: :ok 
            end
            return render json: {room_id: room.id, data: data} ,status: :ok
          else
            return render json: {error: "Current user is not present in room"},status: :unprocessable_entity
          end
        else
          return render json: {error: ROOMERROR},status: :unprocessable_entity
        end
      end
  
      private
  
      def current_user
        return unless @token
        @current_user ||= AccountBlock::Account.find(@token.id)
      end
  
    end
  end
  