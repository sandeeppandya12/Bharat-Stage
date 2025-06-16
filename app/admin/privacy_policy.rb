ActiveAdmin.register BxBlockTermsAndConditions::PrivacyPolicy, as: 'Privacy Policy' do
  menu priority: 13
  permit_params :title, :description
  actions :all, except: [:destroy]
  config.filters = false
  index do
    selectable_column
    id_column
    column :description do |m|
      simple_format(m.description)
    end
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Privacy Policy Details" do
      f.input :description, as: :quill_editor
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
       row "description" do |m|
        simple_format(m.description)
      end
      row :created_at
      row :updated_at
    end
  end
end
