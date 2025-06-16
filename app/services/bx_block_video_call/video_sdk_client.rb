module BxBlockVideoCall
  module VideoSdkClient
    class << self
      def request(uri, request, parsed_token)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request["Authorization"] = parsed_token
        body = http.request(request).body
      end
    end
  end
end
