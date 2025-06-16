ActiveAdmin.register_page "Payments" do
    menu priority: 120, label: "Payments"
  
    controller do
      def export_csv
        razorpay_service = BxBlockRazorpay::RazorpayIntegration.new
        razorpay_subscriptions = razorpay_service.fetch_subscription
  
        if razorpay_subscriptions && razorpay_subscriptions.attributes["items"].present?
          completed_subscriptions = razorpay_subscriptions.attributes["items"].select { |sub| sub['status'] == 'active' || sub['status'] == 'completed' }
  
          if completed_subscriptions.any?
            csv_data = CSV.generate(headers: true) do |csv|
              csv << ['Razorpay Subscription ID', 'Razorpay Plan ID', 'Razorpay Customer ID', 'Email ID', 'Full Phone Number', 'Status', 'Created At', 'Paid Count', 'Remaining Count', 'Short URL']
  
              completed_subscriptions.each do |sub|
                account = AccountBlock::Account.find_by(razorpay_customer_id: sub['customer_id'])
                csv << [
                  sub['id'],
                  sub['plan_id'],
                  sub['customer_id'],
                  account&.email,
                  account&.phone_number,
                  sub['status'].capitalize,
                  Time.at(sub['created_at']).strftime('%Y-%m-%d %H:%M:%S'),
                  sub['paid_count'],
                  sub['remaining_count'],
                  "https://dashboard.razorpay.com/app/subscriptions/#{sub['id']}"
                ]
              end
            end
  
            file_path = Rails.root.join('tmp', "completed_subscriptions_#{Time.now.to_i}.csv")
            File.write(file_path, csv_data)
  
            send_file file_path, type: 'text/csv', filename: File.basename(file_path)
          else
            flash[:alert] = "No completed subscriptions found to export."
            redirect_to admin_payments_path
          end
        else
          flash[:alert] = "No subscriptions found."
          redirect_to admin_payments_path
        end
      end
    end
  
    action_item :export_csv, only: :index do
      link_to "Export Subscriptions to CSV", export_csv_admin_payments_path, method: :post, class: 'button'
    end
  
    content do
      razorpay_service = BxBlockRazorpay::RazorpayIntegration.new
      razorpay_subscriptions = razorpay_service.fetch_subscription
  
      if razorpay_subscriptions && razorpay_subscriptions.attributes["items"].present?
        completed_subscriptions = razorpay_subscriptions.attributes["items"].select { |sub| sub['status'] == 'active' || sub['status'] == 'completed' }
  
        if completed_subscriptions.any?
          completed_subscriptions.each do |subscription_data|
            subscription = OpenStruct.new(subscription_data)
  
            panel '' do
              table_for [subscription] do

                column :first_name do |sub|
                    account = AccountBlock::Account.find_by(razorpay_customer_id: sub.customer_id)
                    account.first_name if account
                end
                column :last_name do |sub|
                    account = AccountBlock::Account.find_by(razorpay_customer_id: sub.customer_id)
                    account.last_name if account
                end

                column :email_id do |sub|
                    account = AccountBlock::Account.find_by(razorpay_customer_id: sub.customer_id)
                    account.email if account
                end
    
                column :full_phone_number do |sub|
                    account = AccountBlock::Account.find_by(razorpay_customer_id: sub.customer_id)
                    account.phone_number if account
                end
                column :razorpay_subscription_id do |sub|
                  sub.id
                end

                column :razorpay_plan_id do |sub|
                  sub.plan_id
                end

                column :razor_pay_customer_id do |sub|
                  sub.customer_id
                end
  
                column :status do |sub|
                  sub.status.capitalize
                end

                column :amount do |sub|
                    plan = BxBlockRazorpay::RazorpayIntegration.new.fetch_plan_details(sub.plan_id)
                    amount = plan[:amount]
                    "#{(amount.to_f).round(2)}"
                end

                column :created_at do |sub|
                    Time.at(sub.created_at).in_time_zone("Asia/Kolkata").strftime("%d-%m-%Y %I:%M %p")
                end

                column :paid_count do |sub|
                  sub.paid_count
                end

                column :remaining_count do |sub|
                  sub.remaining_count
                end
  
                column :short_url do |sub|
                  link_to 'View Subscription', "https://dashboard.razorpay.com/app/subscriptions/#{sub.id}", target: '_blank'
                end
              end
            end
          end
        else
          para "No completed subscriptions found."
        end
      else
        para "No subscriptions found."
      end
    end
  end
  