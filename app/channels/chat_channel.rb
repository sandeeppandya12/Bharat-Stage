class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat = BxBlockChat::Chat.find(params[:id])
    stream_from @chat
  end

  def unsubscribed
    stop_all_streams
  end

  def speak(data)
    @chat = BxBlockChat::Chat.find(params[:id])
    message = BxBlockChat::ChatMessage.create!(account_id: current_user.id, chat_id: @chat.id, message: data["message"])
    if message && @chat.accounts
      @chat.accounts.each do |account|
        if account.id != current_user.id && account.status == "offline" && account.get_email_notifications
          ::BxBlockChat::ChatsMailer.with(
            to: account.email,
            chat: @chat.name
          ).new_message.deliver_later
        end
      end
    end
    ActionCable.server.broadcast @chat, message: message.message
  end

  def self.user_status_update(chats, account_id)
    @account = AccountBlock::Account.find(account_id)
    chats.each do |chat|
      ActionCable.server.broadcast chat, message: {
        account_id: account_id, status: "active", last_request_at: @account.last_request_at
      }.to_json
    end
  end
end

# Example comand of subscribing
# {"command":"subscribe","identifier":"{\"channel\":\"ChatChannel\",\"id\":\"1\"}","data":"{\"id\":\"1\"}"}

# # Example comand of sending message
# {"command":"message","identifier":
#   "{\"channel\":\"ChatChannel\",\"id\":\"1\"}","data":"{\"message\":\"hello from user2\",\"action\":\"speak\"}"}
