module BxBlockContentManagement
end

ActiveAdmin.register BxBlockContentManagement::ContentManagement, as: 'Catalogue'  do
	menu priority: 7
	permit_params :title, :description, :status, :price, :quantity, :user_type, :image, images:[]

	index do
  	selectable_column
    id_column
    column :title
    column :description
    actions
	end

	show do
    attributes_table do
      row :title
      row :description
      row :image do |s|
			  if s&.image.attached?
	        span do
	          image_tag(s.image, height: '100', width: '100') rescue nil
	        end
	      else
	        'No Image'
	      end
			end
      row :created_at
      row :updated_at
    end
	end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
    	f.inputs :title
      f.input :description
	    f.input :image, as: :file
    end
    f.actions
  end
end
