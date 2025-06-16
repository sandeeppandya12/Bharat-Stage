module BxBlockVideoCall
  class RecordingsController < ApplicationController
    def recordings_list
      render json: video_sdk_recordings.execute("get", false, params[:room_id]), status: :ok
    end

    def recording
      render json: video_sdk_recordings.execute("get", params[:recording_id], false)
    end

    def delete_recording
      render json: video_sdk_recordings.execute("delete", params[:recording_id], false)
    end

    private

    def video_sdk_recordings
      VideoSdkRecordings.new
    end
  end
end
