module BxBlockChat
  class MessageBroadcastJob < ApplicationJob
    queue_as :default

    def perform(message, chat)
      ActionCable.server.broadcast chat, message: message
    end
  end
end
