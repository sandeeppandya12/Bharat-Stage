module BxBlockUploadMedia
  class UploadMediaController < ApplicationController
    def create
      begin
        urls = []
      if params[:media].present? && params[:media][:meta].present?
        params[:media][:meta].each do |media_meta|
          upload = BxBlockUploadMedia::Media.new(
            imageable_type: params[:media][:imageable_type],
            imageable_id: params[:media][:imageable_id],
            file_name: media_meta[:file_name],
            file_size: media_meta[:file_size],
            category: media_meta[:category],
            status: "pending"
          )

          if upload.save
            url = BxBlockUploadMedia::UploadPresigner.new.presign(
              "users/1/seller_account/#{upload.category}",
              media_meta[:file_name]
            )
            urls << {
              id: upload.id,
              presigned_url: url[:presigned_url],
              is_visiting: upload.category == "visiting_card"
            }
          else
            return render json: {errors: upload.errors}, status: :unprocessable_entity
          end
        end
        render json: {data: urls}, status: :ok
      else
        render json: {errors: "media or meta missing"}, status: :not_found
      end
      rescue NameError
        render json: {message: "Please enter a valid imageable type."}, status: :unprocessable_entity
      end
    end

    def bulk_upload
      if params[:media].present?
        params[:media].each do |m|
          media = BxBlockUploadMedia::Media.find(m[:id])
          if media.update(status: m[:status], presigned_url: m[:presigned_url])
            render json: {status: :ok, message: "Successfully Updated"}, status: :ok
          else
            render json: {errors: media.errors}, status: :unprocessable_entity
          end
        end
      else
        render json: {errors: "media missing"}, status: :not_found
      end
    end

    def index
      seller_account = BxBlockCustomForm::SellerAccount.find_by_account_id(current_user.id)

      if seller_account.present?
        visiting_card = BxBlockUploadMedia::Media.where(
          imageable_id: seller_account.id,
          imageable_type: "BxBlockCustomForm::SellerAccount", category: "visiting_card"
        )
        photo_gallery = BxBlockUploadMedia::Media.where(
          imageable_id: seller_account.id,
          imageable_type: "BxBlockCustomForm::SellerAccount",
          category: "photo_gallery"
        )
        render json: {visiting_card: visiting_card, photo_gallery: photo_gallery}, status: :ok
      else
        render json: {message: "No data is found with this account"}, status: :not_found
      end
    end

    def upload_banner
      begin
        upload = BxBlockUploadMedia::Media.new(
          imageable_type: banner_params[:imageable_type],
          imageable_id: banner_params[:imageable_id],
          file_name: banner_params[:file_name],
          file_size: banner_params[:file_size],
          category: banner_params[:category],
          status: "pending"
        )
  
        if upload.save
          resp = BxBlockUploadMedia::UploadPresigner.new.presign(
            "users/1/advertise_banner/",
            banner_params[:file_name]
          )
          upload.update(presigned_url: resp[:presigned_url]) if resp[:presigned_url].present?
          render json: {
            id: upload.id, presigned_url: resp[:presigned_url], public_url: resp[:public_url]
          }, status: :ok
        else
          render json: {errors: upload.errors}, status: :unprocessable_entity
        end
      rescue NameError
        render json: {message: "Please enter a valid imageable type."}, status: :unprocessable_entity
      end
    end

    def fetch_advertise_banner
      banners = BxBlockUploadMedia::Media.where(
        imageable_id: params[:id],
        imageable_type: "BxBlockCustomAds::Advertisement"
      )

      if banners.present?
        render json: {banners: banners}, status: :ok
      else
        render json: {message: "no data found"}, status: :not_found
      end
    end

    private

    def banner_params
      params.require(:media).permit(:imageable_type, :imageable_id, :file_name, :file_size, :category)
    end
  end
end
