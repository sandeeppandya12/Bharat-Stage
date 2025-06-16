ActiveAdmin.register BxBlockCategories::SubCategory, as: 'SubCategory' do  
  menu priority: 9

  permit_params :name, :category_id
  actions :all
  
  index do
    selectable_column
    id_column
    column :name
    column :category
  end

  form do |f|
    f.inputs "Category" do
      f.input :name
      f.input :category_id, as: :select, collection: BxBlockCategories::Category.pluck(:name, :id)
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :category_id
      row :created_at
      row :updated_at
    end
  end
  
end