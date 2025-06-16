ActiveAdmin.register BxBlockContentManagement::Subscribe, as: 'Email Subscribers'  do
	 menu priority: 12
	actions :all, except: [:new]

	permit_params :email

	index do
  	selectable_column
    id_column
    column :email
    actions
	end
end