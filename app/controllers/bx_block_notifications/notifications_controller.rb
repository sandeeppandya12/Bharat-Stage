module BxBlockNotifications
  class NotificationsController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :set_notification, only: [:update]

    def index
      notifications = Notification.where('account_id = ?', current_user.id).order(created_at: :desc)
      if notifications.present?
        unread_count = notifications.where(is_read: false).count
        render json: NotificationSerializer.new(
          notifications,
          { meta: { message: "List of notifications." , notification_count: unread_count} }.merge(serialization_options)
        ).serializable_hash, status: :ok
      else
        render json: {errors: [{message: 'No notification found.'},],  meta: { notification_count: 0 }}, status: :ok
      end
    end

    def show
      notification = Notification.find(params[:id])
      render json: NotificationSerializer.new(notification, meta: {
          message: "Success."}).serializable_hash, status: :ok
    end

    def create
      notification = Notification.new(notification_params)
      if notification.save
        render json: NotificationSerializer.new(notification, meta: {
            message: "Notification created."}).serializable_hash, status: :created
      else
        render json: {errors: format_activerecord_errors(notification.errors)},
               status: :unprocessable_entity
      end
    end

    def update
      if @notification.update(is_read: true, read_at: DateTime.now)
        render json: NotificationSerializer.new(@notification, serialization_options).serializable_hash, status: :ok

      else
        render json: {errors: format_activerecord_errors(@notification.errors)},
               status: :unprocessable_entity
      end
    end

    def read_all_notification
      if current_user.notifications.present?
        current_user.notifications.update_all(is_read: true, read_at: DateTime.now)
        render json: NotificationSerializer.new(
          current_user.notifications,
          serialization_options.merge(meta: { message: "All notifications marked as read" })
        ).serializable_hash, status: :ok
      else
        render json: {errors: "Notification not found"},
               status: :not_found
      end
    end

    def destroy
      notification = Notification.find(params[:id])
      if notification.destroy
        render json: {message: "Deleted."}, status: :ok
      else
        render json: {errors: format_activerecord_errors(notification.errors)},
               status: :unprocessable_entity
      end
    end

    private

    def notification_params
      params.require(:notification).permit(
        :headings, :contents, :app_url, :account_id
      ).merge(created_by: @current_user.id, account_id: @current_user.id)
    end

    def format_activerecord_errors(errors)
      result = []
      errors.each do |attribute, error|
        result << { attribute => error }
      end
      result
    end

    def set_notification
      @notification = current_user.notifications.find_by(id: params[:id])
      render json: { error: 'Notification not found' }, status: :not_found unless @notification.present?
    end

    def serialization_options
      { params: { host: request.protocol + request.host_with_port } }
    end

  end
end
