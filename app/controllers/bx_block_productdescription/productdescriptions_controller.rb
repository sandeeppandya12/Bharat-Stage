module BxBlockProductdescription
	class ProductdescriptionsController < ApplicationController

		def index
			@productdescription = BxBlockProductdescription::Productdescription.all
			if @productdescription.present?
				render json:BxBlockProductdescription::ProductdescriptionSerializer.new(@productdescription, meta: {
					message: 'List of products with description'}).serializable_hash
			else
				render json: { message: 'No record present'}
			end
		end
		

		def create		
			@productdescription = BxBlockProductdescription::Productdescription.new(desc_params)
			if @productdescription.present? && @productdescription.save
				render json: BxBlockProductdescription::ProductdescriptionSerializer.new(@productdescription, meta: {
					message: 'Product Description Created Successfully',
				}).serializable_hash, status: :created
			else
				render json: { errors: format_activerecord_errors(@productdescription.errors), status:400  },
				status: :unprocessable_entity
			end
		end

		def update
			@productdescription = BxBlockProductdescription::Productdescription.find(params[:id])
			if @productdescription.update(desc_params)
				render json: BxBlockProductdescription::ProductdescriptionSerializer.new(@productdescription, meta: {
					message: 'Product Description Updated Successfully',
				}).serializable_hash
			else
				render json: "Unprocessable Entity"
			end

		end

		def show
			@productdescription = BxBlockProductdescription::Productdescription.find(params[:id])
			if @productdescription.present?
				render json: BxBlockProductdescription::ProductdescriptionSerializer.new(@productdescription).serializable_hash
			else
				render json: { message: "sorry! No data present with this id" },
				status: :unprocessable_entity
			end
		end

		def destroy
			@productdescription = BxBlockProductdescription::Productdescription.find(params[:id])
			if @productdescription.destroy
				render json: {message: "Deleted Successfully"}
			else
				return render json: { message: 'productdescription with this id does not exists'}
			end
		end

		private

		def desc_params
			params.permit(:product_id, :name, :price, :description, :manufacture_date, :availability, :recommended, :on_sale, :sale_price, images: [])

		end

		def format_activerecord_errors(errors)
			result = []
			errors.each do |attribute, error|
				result << { attribute => error }
			end
			result
		end

	end
end