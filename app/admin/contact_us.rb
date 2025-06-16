ActiveAdmin.register BxBlockContactUs::Contact, as: 'Contact Us'  do
    NUMBER = /\A\+?91/
    actions :all, except: [:new, :create]

    filter :id
    filter :message
  
    permit_params :first_name, :last_name, :email, :full_phone_number, :subject, :message, contact_images: []
  
    menu priority: 10
  
    index title: "Contacts" do
      selectable_column
      id_column
      column :first_name
      column :last_name
      column "Mobile Number" do |contact|
        contact&.full_phone_number.to_s.sub(NUMBER, '')
      end
      column :email
      column :subject
      column :message do |contact|
        truncate(contact.message, length: 30)
      end
      column "Attachments" do |contact|
        if contact.contact_images.attached?
          ul do
            contact.contact_images.each do |image|
              li do
                link_to image.filename.to_s, rails_blob_path(image, only_path: true), target: '_blank'
              end
            end
          end
        else
          "No attachments"
        end
      end
      column :created_at do |contact|
        contact.created_at.in_time_zone("Asia/Kolkata").strftime("%d-%m-%Y %I:%M %p")
      end
      actions
    end
  
    show title: "Contact Details" do
      attributes_table do
        row :id
        row :first_name
        row :last_name
        row "Mobile Number" do |contact|
          contact&.full_phone_number.to_s.sub(NUMBER, '')
        end
        row :email
        row :subject
        row :message
        row :created_at do |contact|
          contact&.created_at.in_time_zone("Asia/Kolkata").strftime("%d-%m-%Y %I:%M %p")
        end
 
        row "Attachments" do |contact|
          if contact.contact_images&.attached?
            ul do
              contact.contact_images.each do |image|
                li do
                  link_to image.filename.to_s, rails_blob_path(image, only_path: true), target: '_blank'
                end
              end
            end
          else
            "No attachments"
          end
        end
      end
      active_admin_comments
    end
  
    form title: "Edit Contact" do |f|
      f.inputs 'Contact Details' do
        f.input :first_name
        f.input :last_name
        f.input :full_phone_number, label: "Mobile Number",
                input_html: { value: f.object&.full_phone_number.to_s.sub(NUMBER, '') }
        f.input :email
        f.input :subject
        f.input :message
        f.input :contact_images, as: :file, input_html: { multiple: true }
      end
      f.actions
    end
  
    filter :first_name
    filter :last_name
    filter :email
    filter :full_phone_number
    filter :subject
    filter :created_at
  end
  