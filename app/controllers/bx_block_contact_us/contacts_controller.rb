module BxBlockContactUs
  class ContactsController < ApplicationController
    def create
      @contact = Contact.new(contact_params)
      @contact.full_phone_number = "+91#{@contact.full_phone_number}" unless @contact.full_phone_number.start_with?("+91")
    
      if @contact.save
        render json: ContactSerializer.new(@contact).serializable_hash, status: :created
      else
        render json: { errors: [{ contact: @contact.errors.full_messages }] }, status: :unprocessable_entity
      end
    end
    
    

    private

    def contact_params
      params.permit(:first_name, :last_name, :email, :full_phone_number, :subject, :message, contact_images: [])
    end
  end
end
