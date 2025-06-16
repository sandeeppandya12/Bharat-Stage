ActiveAdmin.register BxBlockLanguage::UserLanguage, as: "Languages" do
    config.sort_order = 'name_asc'

    menu priority: 4
  
    permit_params :name
  
    index do
      selectable_column
      id_column
      column :name
      actions
    end
  
    show do
      attributes_table do
        row :id
        row :name
      end
    end
  
    form do |f|
      f.inputs do
        f.input :name
      end
      f.actions
    end
  
    filter :name, as: :string
  end
  