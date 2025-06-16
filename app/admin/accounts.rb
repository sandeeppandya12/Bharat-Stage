ActiveAdmin.register AccountBlock::Account do
  MOBILE_NUMBER = "Mobile Number"
  actions :all, except: [:new, :create]

  filter :id
  filter :first_name
  filter :last_name
  filter :full_phone_number, as: :string, label: MOBILE_NUMBER
  filter :email
  filter :activated, as: :boolean
  filter :blocked, as: :boolean
  filter :roles, as: :select, collection: AccountBlock::Account.roles.keys
  filter :created_at
  filter :updated_at

  action_item :export_csv, only: :index do
    link_to "Export Accounts to CSV", export_csv_admin_account_block_accounts_path, method: :post, class: 'button'
  end

  permit_params :first_name, :last_name, :email, :activated, :full_phone_number, :terms_accepted, :blocked, :roles

  before_save do |account|
    existing_account = AccountBlock::Account.where(full_phone_number: account.full_phone_number).where.not(id: account.id).exists?
    if existing_account
      account.errors.add(:full_phone_number, "This mobile number is already taken. Please use another one.")
    end
  end

  menu priority: 2, label: 'Accounts'

  index title: "Accounts" do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column MOBILE_NUMBER do |account|
      account.phone_number
    end
    column :email
    column :activated
    column :created_at do |account|
      account.created_at.in_time_zone("Asia/Kolkata").strftime("%d-%m-%Y %I:%M %p")
    end
    column :updated_at do |account|
      account.updated_at.in_time_zone("Asia/Kolkata").strftime("%d-%m-%Y %I:%M %p")
    end
    column :roles
    column :blocked
    actions defaults: true do |account|
      if account.blocked?
        link_to 'UnBlock', unblock_admin_account_block_account_path(account), method: :put, class: 'member_link'
      else
        link_to 'Block', block_admin_account_block_account_path(account), method: :put, class: 'member_link'
      end
    end
  end

  show title: "Account Details" do
    attributes_table do
      row :id
      row :first_name
      row :last_name
      row MOBILE_NUMBER do |account|
        account.phone_number
      end
      row :email
      row :locations
      row :height
      row :gender
      row :weight
      row :age
      row :created_at do |account|
        account.created_at.in_time_zone("Asia/Kolkata").strftime("%d-%m-%Y %I:%M %p")
      end
      row :updated_at do |account|
        account.updated_at.in_time_zone("Asia/Kolkata").strftime("%d-%m-%Y %I:%M %p")
      end
      row :roles
      row :blocked
    end

    

    panel "Professional Skills" do
      account_sub_category_records = AccountBlock::AccountsSubCategory.where(account_id: resource.id)  # Get all records
      
      if account_sub_category_records.any?  # Check if there are any records
        account_sub_category_records.each do |account_sub_category_record|
          category = account_sub_category_record.sub_category.category
          sub_categories = account_sub_category_record.sub_category
        
          div do
            h4 "Category: #{category.name}" 
        
            if sub_categories
              ul do
                li do
                  "#{sub_categories.name}"
                end
              end
            else
              div "No subcategories available for this category."
            end
          end
        end
      else
        div "No categories and subcategories assigned."
      end
    end


    panel "Languages" do
      if resource.languages.present? && resource.languages.any?
        ul do
          resource.languages.each do |language|
            li language
          end
        end
      else
        div "No languages added."
      end
    end
    
    
    
    panel "About #{resource.first_name} #{resource.last_name}" do
      div do
        div resource.description.presence || "No description available."
      end
    end

    panel "User Educations" do
      if resource.user_educations.any?
        table_for resource.user_educations do
          column :institute_name
          column :qualification
          column :is_ongoing
          column :location
          column :start_date
          column :start_year
          column :end_date
          column :end_year
        end
      else
        div "No education details available."
      end
    end


    panel "User Careers" do
      if resource.user_careers.any?
        table_for resource.user_careers do
          column :project_name
          column :role
          column :is_ongoing
          column :location
          column :start_date
          column :end_year
          column :start_year
          column :end_date
          column "Project Link" do |career|
            if career.project_link.present?
              career.project_link.join(", ")
            else
              "No project links available"
            end
          end
          column "Career Image" do |career|
            if career.career_image.attached?
              span do
                image_tag(career.career_image, height: '100', width: '100') rescue nil
              end
            
            else
              "No career image uploaded"
            end
          end
        end
      else
        div "No career details available."
      end
    end

    panel "Portfolio Links" do
      if resource.user_links.present?
        ul do
          resource.user_links.each do |link|
            li do
              # Access the `value` of each UserLink and make it clickable
              link_to link.value, link.value, target: "_blank"
            end
          end
        end
      else
        div "No Portfolio links available."
      end
    end

    panel "Portfolio Media" do
      if resource.upload_media.attached?
        div style: "display: flex; flex-wrap: wrap; gap: 20px;" do
          resource.upload_media.each do |media|
            div style: "border: 1px solid #e0e0e0; padding: 10px; border-radius: 8px; background-color: #f9f9f9; text-align: center;" do
              if media.image?
                image_tag url_for(media), size: "150x150", style: "border-radius: 5px; max-width: 100%;"
              else
                link_to media.filename.to_s, url_for(media), target: "_blank"
              end
            end
          end
        end
      else
        div "No media files uploaded."
      end
    end
    
    

    panel "Social Media Links" do
      if resource.social_media_links.present?
        ul do
          resource.social_media_links.each do |platform, link|
            li do
              if link.present?
                link_to "#{platform.capitalize}: #{link}", link, target: "_blank"
              else
                "#{platform.capitalize}: No link provided"
              end
            end
          end
        end
      else
        div "No social media links available."
      end
    end

  end

  form title: "Edit Account" do |f|
    f.inputs 'Account Details' do
      f.input :first_name
      f.input :last_name
      f.input :phone_number, label: MOBILE_NUMBER,
        input_html: { value: f.object.phone_number }
      f.input :email
      f.input :roles, as: :select, collection: AccountBlock::Account.roles.keys, include_blank: false, input_html: { style: 'width: 300px; padding: 10px 5px;' }
      f.input :activated
      f.input :blocked, as: :boolean
    end
    f.actions
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :blocked
  filter :roles
  filter :date_of_birth
  filter :created_at

 

  collection_action :export_csv, method: :post do
    file_path = AccountBlock::ExportAccountsCsvJob.perform_now # Run the job synchronously and get the file path

    if File.exist?(file_path)
      send_file file_path, type: 'text/csv', filename: File.basename(file_path)
    else
      flash[:alert] = "CSV file could not be generated."
      redirect_to admin_account_block_accounts_path
    end
  end

  member_action :block, method: :put do
    resource.update_column(:blocked, true)
    redirect_to admin_account_block_accounts_path, notice: "Account Blocked successfully!"
  end

  member_action :unblock, method: :put do
    resource.update_column(:blocked, false)
    redirect_to admin_account_block_accounts_path, notice: "Account Unblocked successfully!"
  end
end
