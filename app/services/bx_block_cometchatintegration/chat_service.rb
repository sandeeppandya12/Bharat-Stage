module BxBlockCometchatintegration
  class ChatService
    include HTTParty

    require 'uri'
    require 'net/http'
    require 'openssl'
    URL = ENV['COMET_CHAT_URL']

    def self.send_message(sender_uid, receiver_uid, message, media_file = nil)
      url = URI("#{URL}/messages")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "post")
      request["onBehalfOf"] = sender_uid

      if media_file.present?
        file_url = upload_media_to_minio(media_file)
      end

      request_body = {
        "category" => "message",  # Always 'message' for sending a message
        "type" => media_file.present? ? "image" : "text",
        "data" => {
          "text" => message,  # Optional text message accompanying the media
          "attachments" => [
            {
              "url" => file_url,  # URL to the media (uploaded to MinIO or other storage)
              "name" => media_file.present? ? media_file.original_filename : nil,
              "mimeType" => media_file.present? ? media_file.content_type: nil,  # MIME type of the file
              "extension" => media_file.present? ? media_file.original_filename.split('.').last: nil,  # File extension (e.g., 'mp4', 'jpg')
              "size" => media_file.present? ? media_file.size.to_s : nil  # Size of the file in bytes as a string
            }
          ]
        },
        "receiver" => receiver_uid,  # Receiver UID (the person or group you're sending the message to)
        "receiverType" => "user"  # 'user' for individual messages, 'group' for group messages
      }
      
      request.body = request_body.to_json
      response = http.request(request)
      return response
    end

    def self.setup_minio_client
      Aws::S3::Client.new(
        endpoint: ENV['STORAGE_ENDPOINT'],  # MinIO URL (e.g., http://localhost:9000)
        access_key_id: ENV['STORAGE_ACCESS_KEY'],
        secret_access_key: ENV['STORAGE_SECRET_ACCESS_KEY'],
        region: ENV['STORAGE_REGION'],  # Specify your region
        force_path_style: true
      )
    end

    def self.upload_media_to_minio(media_file)
      s3_client = setup_minio_client
      bucket_name = ENV['STORAGE_BUCKET'] 
      file_name = media_file.original_filename

      s3_client.put_object(
        bucket: bucket_name,
        key: file_name,
        body: media_file.tempfile,
        acl: 'public-read'  # Make the file publicly accessible
      )

      file_url = "#{ENV['STORAGE_ENDPOINT']}/#{bucket_name}/#{file_name}"
      return file_url
    end



    def self.set_request_header(url, type)
      case type
        when "get"
          request = Net::HTTP::Get.new(url)
        when "post"
          request = Net::HTTP::Post.new(url)
        when "put"
          request = Net::HTTP::Put.new(url)
        when "delete"
          request = Net::HTTP::Delete.new(url)
        else
          puts "Something went wrong. Please try again"
      end
      request["apikey"] = ENV['COMETCHAT_API_KEY']
      request["Content-Type"] = 'application/json'
      request["Accept"] = 'application/json'
      request
    end

    def self.get_user_conversation(on_behalf_of_id)
      url = URI("#{URL}/messages?limit=100")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "get")
      request["onBehalfOf"] = on_behalf_of_id
      http.request(request)
    end

    def self.mark_as_delivered(sender_uid, receiver_uid)
      url = URI("#{URL}/users/#{receiver_uid}/conversation/delivered")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "post")
      request["onBehalfOf"] = sender_uid
      http.request(request)
    end

    def self.mark_as_read(sender_uid, receiver_uid)
      url = URI("#{URL}/users/#{receiver_uid}/conversation/read")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "post")
      request["onBehalfOf"] = sender_uid
      http.request(request)
    end

    def self.block_user(sender_uid, receiver_uid)
      url = URI("#{URL}/users/#{sender_uid}/blockedusers")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "post")
      request.body = "{\"blockedUids\":[\"#{receiver_uid}\"]}"
      http.request(request)
    end

    def self.unblock_user(sender_uid, receiver_uid)
      url = URI("#{URL}/users/#{sender_uid}/blockedusers")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "delete")
      request.body = "{\"blockedUids\":[\"#{receiver_uid}\"]}"
      http.request(request)
    end

    def self.delete_message(message_id, sender_uid)
      url = URI("#{URL}/messages/#{message_id}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "delete")
      request["onBehalfOf"] = sender_uid
      request.body = "{\"permanent\":true}"
      http.request(request)
    end

    def self.fetch_conversations(sender_uid, search_query)
      url = URI("#{URL}/users/#{sender_uid}/conversations")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "get")
      request["onBehalfOf"] = sender_uid
      http.request(request)
    end

    def self.get_all_chat(on_behalf_of_id)
      url = URI("#{URL}/conversations?conversationType=user")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "get")
      request["onBehalfOf"] = on_behalf_of_id
      http.request(request)
    end

    def self.delete_user_conversation(conversation_id)
      url = URI("#{URL}/conversations/#{conversation_id}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "delete")
      request.body = "{\"permanent\":true}"
      http.request(request)
    end

    def self.update_user_profile_name(user_id, full_name)
      url = URI("#{URL}/users/#{user_id}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = set_request_header(url, "put")
      request.body = {
        name: full_name
      }.to_json

      response = http.request(request)
      Rails.logger.info "CometChat name update response: #{response.code} - #{response.body}"
      response
    rescue => e
      Rails.logger.error "CometChat name update failed: #{e.message}"
    end
  end
end
