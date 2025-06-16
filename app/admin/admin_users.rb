module AdminUsers
  extend TemplateLoadHelper
end

if AdminUsers.page_registered?("AdminUser") && AdminUsers.is_being_loaded_from_app?
  AdminUsers.unload_activeadmin_resource("AdminUser")
end

unless AdminUsers.page_registered?("AdminUsers")
  ActiveAdmin.register AdminUser do
    permit_params :email, :password, :password_confirmation

    menu priority: 3

    index do
      selectable_column
      id_column
      column :email
      column :current_sign_in_at
      column :sign_in_count
      column :created_at
      actions
    end

    filter :email
    filter :current_sign_in_at
    filter :sign_in_count
    filter :created_at

    form do |f|
      f.inputs do
        f.input :email
        f.input :password
        f.input :password_confirmation
      end
      f.actions
    end

    controller do
      def create
        account_info = params[:admin_user]
        super do |success, failure|
          if success && resource.valid?
            publish_analytics_event('admin.account.created', account_info.except(:password, :password_confirmation, :email))
          else
            handle_error_messages
          end
        end
      end

      def show
        super do |success, failure|
          if success && resource.valid?
            publish_analytics_event('admin.account.show', account_id: resource.id)
          else
            handle_error_messages
          end
        end
      end

      def update
        account_info = params[:admin_user].except(:password, :password_confirmation, :email)
        super do |success, failure|
          if success && resource.valid?
            publish_analytics_event('admin.account.updated', account_info)
          else
            handle_error_messages
          end
        end
      end

      def destroy
        super do |success, failure|
          if success
            publish_analytics_event('admin.account.destroy', {account_id: resource.id})
          else
            handle_error_messages
          end
        end
      end

      private

      def publish_analytics_event(event_name, properties)
        analytics_data = {
          identifier: current_admin_user.id,
          properties: properties,
          event_name: event_name
        }
        analytics_data[:properties] = analytics_data[:properties].merge(action_by: current_admin_user.id, account_id: resource.id)
        BuilderBase::AnalyticsEvent.publish(analytics_data)
      end

      def handle_error_messages
        flash.now[:alert] = resource.errors.full_messages.join(' & ')
      end
    end
  end
end
