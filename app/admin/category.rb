ActiveAdmin.register BxBlockCategories::Category, as: 'Category' do  
  menu priority: 8
  permit_params :name

	config.filters = false

	index do
    selectable_column
    id_column
    column :name
  end

	form do |f|
    f.inputs "Category" do
      f.input :name
    end
    f.actions
  end

	show do
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at
    end
  end

end