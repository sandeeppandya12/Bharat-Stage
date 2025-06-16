ActiveAdmin.register BxBlockContentManagement::Testimonial, as: 'Testimonial'  do
  menu priority: 6
	permit_params :name, :designation, :content, :profile_image

	index do
  	selectable_column
    id_column
    column :name
    column :designation
    column :content
    actions
	end

	show do
    attributes_table do
      row :name
      row :designation
      row :content
      row :profile_image do |s|
			  if s.profile_image.attached?
	        span do
	          image_tag(s.profile_image, height: '100', width: '100') rescue nil
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
    	f.inputs :name
      f.input :designation
      f.input :content
	    f.input :profile_image, as: :file
    end
    f.actions
  end
end
