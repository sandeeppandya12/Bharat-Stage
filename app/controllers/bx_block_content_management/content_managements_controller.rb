module BxBlockContentManagement
  class ContentManagementsController < ApplicationController
    # skip_before_action :validate_json_web_token
    def index
      @contents = BxBlockContentManagement::ContentManagement.all
      if @contents.present?
        render json: BxBlockContentManagement::ContentSerializer.new(@contents, serialization_options.merge(meta: { message: 'List of all contents' })).serializable_hash, status: :ok
      else
        render json: {message: 'No Content is present'} , status: :unprocessable_entity
      end 
    end

    def landing_page
      @landing_page = LandingPage.all
      if @landing_page.present?
        render json: LandingPageSerializer.new(@landing_page, serialization_options).serializable_hash, status: :ok
      else
        render json: {message: 'No Content is present'} , status: :unprocessable_entity
      end 
    end

    def testimonials
      @testimonials = Testimonial.all
      if @testimonials.present?
        render json: TestimonialSerializer.new(@testimonials, serialization_options).serializable_hash, status: :ok
      else
        render json: {message: 'No Content is present'} , status: :unprocessable_entity
      end 
    end

    def subscribe_email 
      subscribe = Subscribe.new(subscribe_params)
      if subscribe.save
        render json: { message: "Subscribed successfully", data: subscribe }, status: :created
      else
        render json: { error: subscribe.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # def approved
    #   @contents = BxBlockContentManagement::ContentManagement.where(status:true)
    #   if @contents.present?
    #     render json: BxBlockContentManagement::ContentSerializer.new(
    #       @contents, meta: {message: 'List of approved contents'}
    #     ).serializable_hash
    #   else
    #     render json: { error: "Content Management not found" }
    #   end
    # end

    # def user_type
    #   @contents = BxBlockContentManagement::ContentManagement.where(user_type: params[:user_type])
    #   @contents = @contents.or(BxBlockContentManagement::ContentManagement.where.not(user_type: params[:user_type]).where(status: true))
    #   if @contents.present?
    #     render json: BxBlockContentManagement::ContentSerializer.new(@contents,  meta: {message: 'List of all contents'}), status: :ok
    #   else
    #     render json: { error: "Content not found" }
    #   end
    # end

    # def create
    #   @content = BxBlockContentManagement::ContentManagement.new(content_params)
    #   if @content.save
    #     render json: BxBlockContentManagement::ContentSerializer.new(@content, meta: {
    #       message: 'Content Created Successfully',
    #     }).serializable_hash, status: :created
    #   else
    #     render json: { errors: format_activerecord_errors(@content.errors) },
    #            status: :unprocessable_entity
    #   end
    # end

    # def show
    #   @content = BxBlockContentManagement::ContentManagement.find_by(id: params[:id])
    #   if @content
    #     render json: BxBlockContentManagement::ContentSerializer.new(@content, meta: {
    #       message: "Content details are updated."}).serializable_hash, status: :ok
    #   else
    #     render json: { error: "Content not found" }
    #   end
    # end

    # def update
    #   @content = BxBlockContentManagement::ContentManagement.find(params[:id])
    #   if @content.update(content_params)
    #     render json: BxBlockContentManagement::ContentSerializer.new(@content, meta: {
    #       message: "Content details are updated."}).serializable_hash, status: :ok
    #   else
    #     render json: {errors: format_activerecord_errors(@content.errors)},
    #            status: :unprocessable_entity
    #   end
    # end

    # def destroy
    #   @content = BxBlockContentManagement::ContentManagement.find(params[:id])
    #   if @content.destroy
    #     render json: {message: "Content info Deleted."}, status: :ok
    #   else
    #     render json: {errors: format_activerecord_errors(@content.errors)},
    #            status: :unprocessable_entity
    #   end
    # end

    private
    
    def subscribe_params
      params.require(:subscribe).permit(:email)
    end

    def serialization_options
      { params: { host: request.protocol + request.host_with_port } }
    end

    # def content_params
    #   params.permit(
    #     :title, :id, :description, :status,  :price, :user_type, :quantity, :publish_date, images: []
    #   )
    # end

  end
end
