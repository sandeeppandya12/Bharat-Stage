module BxBlockVideoCall
  module GenerateVideoSdkToken
    class << self
      def now
        Time.now
      end

      def video_sdk_payload
        {
          apikey: ENV["VIDEOSDK_API_KEY"],
          permissions: ["allow_join", "allow_mod"],
          iat: now.to_i,
          exp: (now + 86400).to_i
        }
      end

      def video_sdk_token
        @video_sdk_token = JWT.encode(video_sdk_payload, ENV["VIDEOSDK_SECRET_KEY"], "HS256")
      end
    end
  end
end
