module Dashboard
  class Load
    @@loaded_from_gem = false
    def self.is_loaded_from_gem
      @@loaded_from_gem
    end

    def self.loaded
    end

    @@loaded_from_gem = Load.method('loaded').source_location.first.include?('bx_block_')
  end
end
unless Dashboard::Load.is_loaded_from_gem
  ActiveAdmin.register_page "Dashboard" do
    DASHBOARD_PANEL = "dashboard-panel"
    CHART_CONTAINER = "chart-container"

    menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

    content title: proc { I18n.t("active_admin.dashboard") } do
      style = <<-CSS
      .dashboard-tabs {
        display: flex;
        gap: 10px;
        margin-bottom: 20px;
        justify-content: left;
      }

      .dashboard-tab {
        background-color: #007bff;
        color: white;
        padding: 10px 20px;
        border-radius: 5px;
        font-size: 16px;
        font-weight: bold;
        text-align: left;
        cursor: pointer;
        border: none;
        transition: background 0.3s ease;
      }

      .dashboard-tab:hover {
        background-color: #0056b3;
      }

      .tab-content {
        display: none;
        margin-top: 20px;
        text-align: center;
      }

      .tab-content.active {
        display: block;
      }

      .hide-content {
        display: none;
      }

      .chart-container {
        width: 50%;
        max-width: 600px;
        margin: auto;
      }
      CSS

      render inline: "<style>#{style}</style>".html_safe

      div class: "dashboard-tabs" do
        button "Registered Users", class: "dashboard-tab", id: "show_chart_tab"
        button "User Gender Count", class: "dashboard-tab", id: "show_users_tab"
        button "User Role Count", class: "dashboard-tab", id: "show_role_tab"
        button "User Language Count", class: "dashboard-tab", id: "show_languages_tab"
        button "User Locations Count", class: "dashboard-tab", id: "show_locations_tab"
        button "User Category Count", class: "dashboard-tab", id: "show_category_list"
        button "Subscription", class: "dashboard-tab", id: "show_razorpay_list"
      end

      div do
        para link_to "Download User Data (CSV)", admin_dashboard_export_path(format: :csv), class: "button"
      end

      start_date = params[:start_date].present? ? params[:start_date].to_date.beginning_of_day : 6.months.ago.beginning_of_month
      end_date = params[:end_date].present? ? params[:end_date].to_date.end_of_day : Time.current.end_of_day

      total_users = AccountBlock::Account.where(created_at: start_date..end_date)
                                         .group_by_month(:created_at, format: "%b %Y").count

      activated_users = AccountBlock::Account.where(activated: true, blocked: false)
                                             .where(created_at: start_date..end_date)
                                           .group_by_month(:created_at, format: "%b %Y").count

      div class: DASHBOARD_PANEL, id: "userStatisticsPanel" do
        panel "User Statistics" do
          div class: "filters mb-4" do
            div do
              label "Start Date", class: "mr-2"
              input type: "date", id: "start_date", name: "start_date", value: params[:start_date], class: "rounded p-2 border"
            end

            div do
              label "End Date", class: "mr-2"
              input type: "date", id: "end_date", name: "end_date", value: params[:end_date], class: "rounded p-2 border"
            end

            div do
              button "Apply Filter", id: "filter_chart", class: "bg-blue-500 text-white rounded px-4 py-2"
            end
          end

          div class: CHART_CONTAINER do
            div class: "mb-6" do
              h3 "Total vs Activated Users", class: "text-lg font-semibold"
              div do
                if total_users.present? || activated_users.present?
                  line_chart [
                    { name: "All Registered Users", data: total_users, color: "orange" },
                    { name: "Activated Users", data: activated_users, color: "blue" }
                  ], library: {
                    title: { text: 'User Registrations Over Time' },
                    xAxis: { title: 'Month & Year' },
                    yAxis: { title: 'Total Users' },
                    legend: { enabled: true } 
                  }
                else
                  para "No user registration data available."
                end
              end
            end
          end
        end
      end

      div id: "registered_users_chart", class: "tab-content" do
        panel "Total & Activated Users Over Time", class: DASHBOARD_PANEL do
          div class: CHART_CONTAINER do

            total_users = AccountBlock::Account.group_by_month(:created_at, format: "%b %Y").count
            activated_users = AccountBlock::Account.where(activated: true, blocked: false).group_by_month(:created_at, format: "%b %Y").count

            if total_users.present? || activated_users.present?
              line_chart [
                { name: "All Registered Users", data: total_users, color: "orange" },
                { name: "Activated Users", data: activated_users, color: "blue" }
              ], library: {
                title: { text: 'User Registrations Over Time' },
                xAxis: { title: 'Month & Year' },
                yAxis: { title: 'Total Users' },
                legend: { enabled: true } 
              }
            else
              para "No user registration data available."
            end
          end

        end
      end

      div id: "user_list", class: "tab-content" do
        style = <<-CSS
          .user-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
          }
          .user-table th, .user-table td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: center;
            white-space: nowrap;
          }
          .user-table th {
            background-color: #007bff;
            color: white;
            font-weight: bold;
          }
          .user-table tr:nth-child(even) {
            background-color: #f2f2f2;
          }
          .user-table tr:hover {
            background-color: #ddd;
          }
        CSS

        render inline: "<style>#{style}</style>".html_safe

        panel "Gender Count Summary" do
          users = AccountBlock::Account.select(:gender)
          gender_counts = users.group_by(&:gender).transform_values(&:count)

          table class: "user-table" do
            thead do
              tr do
                th "Gender"
                th "Count"
              end
            end
            tbody do
              tr do
                td "Male"
                td gender_counts["male"] || 0
              end
              tr do
                td "Female"
                td gender_counts["female"] || 0
              end
              tr do
                td "Other"
                td gender_counts["other"] || 0
              end
            end
          end
        end
      end

      div id: "role_list", class: "tab-content" do
        panel "User Role Count Summary" do
          users = AccountBlock::Account.select(:roles)
          role_counts = users.group_by(&:roles).transform_values(&:count)

          table class: "user-table" do
            thead do
              tr do
                th "Role"
                th "Count"
              end
            end
            tbody do
              role_counts.each do |role, count|
                tr do
                  td role.presence || "Unknown"
                  td count
                end
              end
            end
          end
        end
      end

      users = AccountBlock::Account.pluck(:languages).compact&.flatten
      language_counts = users.reject(&:blank?).tally 

      div id: "language_list", class: "tab-content" do
        panel "User Language Count Summary" do
          if language_counts.present?
            table class: "user-table" do
              thead do
                tr do
                  th "Language"
                  th "Count"
                end
              end
              tbody do
                language_counts.each do |language, count|
                  tr do
                    td language
                    td count
                  end
                end
              end
            end
          else
            para "No language data available."
          end
        end
      end

      indian_states = [
        "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat",
        "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh",
        "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
        "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh",
        "Uttarakhand", "West Bengal"
      ]

      users = AccountBlock::Account.pluck(:locations).compact.reject(&:blank?)
      state_counts = users.tally 
      state_counts = indian_states.map { |state| [state, state_counts[state] || 0] }.to_h
      div id: "locations_list", class: "tab-content" do
        panel "User State Count Summary" do
          table class: "user-table" do
            thead do
              tr do
                th "State"
                th "User Count"
              end
            end
            tbody do
              state_counts.each do |state, count|
                tr do
                  td state
                  td count
                end
              end
            end
          end
        end
      end

      div id: "category_list", class: "tab-content" do
        panel "User Count by Category & Subcategory" do
          category_table = BxBlockCategories::Category.table_name
          subcategory_table = BxBlockCategories::SubCategory.table_name

          category_counts = AccountBlock::AccountsSubCategory
            .joins(sub_category: :category)
            .group("#{category_table}.name")
            .count

          subcategory_counts = AccountBlock::AccountsSubCategory
            .joins(sub_category: :category)
            .group("#{category_table}.name", "#{subcategory_table}.name")
            .count

          if category_counts.present?
            table class: "user-table" do
              thead do
                tr do
                  th "Category", colspan: 2, style: "text-align: center;"
                  th "Subcategory", colspan: 2, style: "text-align: center;"
                end
                tr do
                  th "Category Name"
                  th "User Count"
                  th "Subcategory Name"
                  th "User Count"
                end
              end
              tbody do
                category_counts.each do |category_name, category_user_count|
                  subcategories = subcategory_counts.select { |(cat, _), _| cat == category_name }

                  rowspan = subcategories.size.positive? ? subcategories.size : 1

                  tr do
                    td rowspan: rowspan, style: "vertical-align: middle; text-align: center;" do
                      strong category_name
                    end
                    td rowspan: rowspan, style: "vertical-align: middle; text-align: center;" do
                      strong category_user_count
                    end

                    if subcategories.any?
                      first_subcat, first_subcat_count = subcategories.first
                      td first_subcat[1], style: "text-align: center;" 
                      td first_subcat_count, style: "text-align: center;" 
                    else
                      td "No Subcategories", colspan: 2, style: "text-align: center;"
                    end
                  end

                  subcategories.drop(1).each do |((_, subcat_name), subcategory_user_count)|
                    tr do
                      td subcat_name, style: "text-align: center;"
                      td subcategory_user_count, style: "text-align: center;"
                    end
                  end
                end
              end
            end
          else
            para "No category and subcategory data available."
          end
        end
     
        panel "User Expertise Level Count Summary" do
          experience_counts = AccountBlock::AccountsSubCategory.where.not(experience_level: nil).group(:experience_level).count
          if experience_counts.present?
            table class: "user-table" do
              thead do
                tr do
                  th "Expertise Level"
                  th "User Count"
                end
              end
              tbody do
                experience_counts.each do |level, count|
                  expertise_name = level.present? ? level.capitalize : "Unknown"
                  tr do
                    td expertise_name  
                    td count
                  end
                end
              end
            end
          else
            para "No expertise level data available."
          end
        end
      end

      div id: "razorpay_list", class: "tab-content" do
        panel "Razorpay Subscription Summary" do
          stats = BxBlockRazorpay::RazorpayIntegration.new.fetch_subscription_stats
      
          if stats.present?
            table class: "user-table" do
              thead do
                tr do
                  th "Metric"
                  th "Value"
                end
              end
              tbody do
                tr do
                  td "Total Amount (INR)"
                  td number_to_currency(stats[:total_amount], unit: "₹")
                end
                tr do
                  td "Active Subscriptions"
                  td stats[:active_subscriptions]
                end
                tr do
                  td "Monthly Subscriptions"
                  td stats[:monthly_count]
                end
                tr do
                  td "Yearly Subscriptions"
                  td stats[:yearly_count]
                end
              end
            end
          else
            para "Unable to fetch subscription stats at the moment."
          end
        end
      end
      

      script = <<-JS
        document.addEventListener("DOMContentLoaded", function () {
          let showChartTab = document.getElementById("show_chart_tab");
          let razorPayListContent = document.getElementById("razorpay_list");
          let showRazorpayTab = document.getElementById("show_razorpay_list");
          let showRoleTab = document.getElementById("show_role_tab");
          let showLanguagesTab = document.getElementById("show_languages_tab");
          let showLocationsTab = document.getElementById("show_locations_tab");
          let showCategoryTab = document.getElementById("show_category_list"); 
          let showUsersTab = document.getElementById("show_users_tab");
          let chartContent = document.getElementById("registered_users_chart");
          let userListContent = document.getElementById("user_list");
          let roleListContent = document.getElementById("role_list");
          let languageListContent = document.getElementById("language_list");
          let stateListContent = document.getElementById("locations_list");
          let categoryListContent = document.getElementById("category_list");
          const filterButton = document.getElementById("filter_chart");

          function hideAllTabs() {
            [chartContent, userListContent, roleListContent, languageListContent, stateListContent, categoryListContent, razorPayListContent].forEach(tab => {
              tab.classList.remove("active");
            });
            const userStatisticsPanel = document.getElementById("userStatisticsPanel");
            if (userStatisticsPanel) {
              userStatisticsPanel.style.display = "none";
            }         
          }

          showChartTab.addEventListener("click", function () {
            hideAllTabs();
            chartContent.classList.add("active");
          });

          showUsersTab.addEventListener("click", function () {
            hideAllTabs();
            userListContent.classList.add("active");
          });

          showRoleTab.addEventListener("click", function () {
            hideAllTabs();
            roleListContent.classList.add("active");
          });

          showRazorpayTab.addEventListener("click", function(){
            hideAllTabs();
            razorPayListContent.classList.add("active")
          });

          showLanguagesTab.addEventListener("click", function () {
            hideAllTabs();
            languageListContent.classList.add("active");
          });

          showLocationsTab.addEventListener("click", function () {
            hideAllTabs();
            stateListContent.classList.add("active");
          });

          showCategoryTab.addEventListener("click", function () {
            hideAllTabs();
            categoryListContent.classList.add("active");
          });
 
          if (filterButton) {
            filterButton.addEventListener("click", function () {
              const startDate = document.getElementById("start_date").value;
              const endDate = document.getElementById("end_date").value;

              const url = new URL(window.location.href);
              if (startDate) url.searchParams.set("start_date", startDate);
              if (endDate) url.searchParams.set("end_date", endDate);

              window.location.href = url.toString();
            });
          }

        });
      JS

      render inline: "<script>#{script}</script>".html_safe
    end

    page_action :export, method: :get do
      csv_data = CSV.generate(headers: true) do |csv|
        sections = {
          "Gender" => AccountBlock::Account.group(:gender).count.transform_keys { |k| k || "Unknown" },
          "Languages" => AccountBlock::Account.where.not(languages: nil).pluck(:languages).flatten.tally,
          "Locations" => AccountBlock::Account.where.not(locations: nil).pluck(:locations).tally,
          "Roles" => AccountBlock::Account.group(:roles).count.transform_keys { |k| k || "Unknown" }
        }

        sections.each do |title, data|
          csv << []
          csv << [title, "", ""]
          data.each { |key, count| csv << ["", key, count] }
        end

        csv << []
        csv << ["Category & Subcategory", "", ""]
        category_table = BxBlockCategories::Category.table_name
        subcategory_table = BxBlockCategories::SubCategory.table_name

        category_counts = AccountBlock::AccountsSubCategory
          .joins(sub_category: :category)
          .group("#{category_table}.name")
          .count

        subcategory_counts = AccountBlock::AccountsSubCategory
          .joins(sub_category: :category)
          .group("#{category_table}.name", "#{subcategory_table}.name")
          .count

        category_counts.each do |category_name, category_count|
          csv << ["Category", category_name, category_count]

          subcategories = subcategory_counts.select { |(cat, _), _| cat == category_name }
          subcategories.each do |(category, subcategory), subcategory_count|
            csv << ["", subcategory, subcategory_count] # Indent subcategory under its category
          end
        end

        csv << [] 
        csv << ["Expertise Level", "", ""]
        experience_counts = AccountBlock::AccountsSubCategory.where.not(experience_level: nil).group(:experience_level).count
        experience_counts.each do |level, count|
          csv << ["", level.present? ? level.capitalize : "Unknown", count]
        end
      end
      send_data csv_data, filename: "user_data_#{Date.today}.csv", type: 'text/csv'
    end
  end 
end
