module BxBlockVideoCall
  class VideoSdkMeeting
    attr_accessor :uri, :body, :parsed_token, :json_data, :request

    def initialize
      @parsed_token = generate_token
    end

    def generate_token
      GenerateVideoSdkToken.video_sdk_token
    end

    def meeting(meeting_id)
      meeting_uri(meeting_id)
      meeting_request
      video_sdk_client_request
      meeting_id_from_body
    end

    private

    def meeting_uri(meeting_id)
      @uri = if meeting_id
        URI("#{ENV["VIDEOSDK_API_ENDPOINT"]}/api/meetings/#{meeting_id}")
      else
        URI("#{ENV["VIDEOSDK_API_ENDPOINT"]}/api/meetings")
      end
    end

    def meeting_request
      @request = Net::HTTP::Post.new(uri.path)
    end

    def meeting_id_from_body
      if body == "Meeting ID is invalid."
        meeting(false)
      else
        @json_data = JSON.parse(body, object_class: OpenStruct)
        meeting_id_for_valid_token
        json_data.meetingId
      end
    end

    def meeting_id_for_valid_token
      if json_data.error == "Token is expired or invalid"
        @parsed_token = generate_token
        meeting(false)
      end
    end

    def video_sdk_client_request
      @body = VideoSdkClient.request(uri, request, parsed_token)
    end
  end
end
