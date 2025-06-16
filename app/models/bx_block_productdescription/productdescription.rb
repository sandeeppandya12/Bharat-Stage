module BxBlockProductdescription
	class Productdescription < BuilderBase::ApplicationRecord
		include ActiveStorage::Blob::Analyzable
		include Wisper::Publisher
		self.table_name = :bx_block_productdescription_productdescriptions
		validates :product_id, :description, :price, presence: true
# Protected Area Start
		has_many_attached :images , dependent: :destroy
# Protected Area End
	end
end



