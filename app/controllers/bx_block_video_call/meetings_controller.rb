module BxBlockVideoCall
  class MeetingsController < ApplicationController
    before_action :find_group_member, only: [:meeting_link]

    def member_groups
      member_groups ||= BxBlockAccountGroups::AccountGroup.where(account_groups_group_id: params[:group_id])
      render json: {data: member_groups}, status: :ok
    end

    def member_groups_for_chat
      BxBlockChat::Chat.eager_load(:accounts_chats)
    end

    def meeting_link
      video_sdk_meeting_id = if group.meeting_id?
        video_sdk_meeting.meeting(group.meeting_id)
      else
        video_sdk_meeting.meeting(false)
      end

      group.update!(meeting_id: video_sdk_meeting_id)

      render json: {
        meeting_id: video_sdk_meeting_id,
        token: video_sdk_meeting.generate_token
      }, status: :ok
    end

    private

    def video_sdk_meeting
      VideoSdkMeeting.new
    end

    def group
      @group ||= BxBlockAccountGroups::Group.find_by(id: params[:group_id])
    end

    def group_member
      @members ||= BxBlockAccountGroups::AccountGroup.find_by(account_id: @token.id, account_groups_group_id: params[:group_id])
    end

    def find_group_member
      unless group_member
        render json: {errors: "This member does not exists in that group"},
          status: :not_acceptable and return
      end
    end
  end
end
