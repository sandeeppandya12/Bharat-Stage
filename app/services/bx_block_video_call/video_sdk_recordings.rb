module BxBlockVideoCall
  class VideoSdkRecordings
    attr_accessor :uri, :body, :json_data, :request, :parsed_token

    def initialize
      @parsed_token = generate_token
    end

    def generate_token
      GenerateVideoSdkToken.video_sdk_token
    end

    def execute(method, recording_id, room_id)
      recording_uri(recording_id, room_id)
      recording_request(method)
      video_sdk_client_request
      recording_data_from_body
    end

    private

    def recording_uri(recording_id, room_id)
      @uri = if room_id
        URI("#{ENV["VIDEOSDK_API_ENDPOINT"]}/v2/recordings?roomId=#{room_id}")
      else
        URI("#{ENV["VIDEOSDK_API_ENDPOINT"]}/v2/recordings/#{recording_id}")
      end
    end

    def recording_request(method)
      @request = if method == "get"
        Net::HTTP::Get.new(uri, "Content-Type" => "application/json")
      else
        Net::HTTP::Delete.new(uri, "Content-Type" => "application/json")
      end
    end

    def recording_data_from_body
      @json_data = JSON.parse(body)
    end

    def video_sdk_client_request
      @body = VideoSdkClient.request(uri, request, parsed_token)
    end
  end
end
