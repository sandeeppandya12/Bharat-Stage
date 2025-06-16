module BxBlockUploadMedia
  class UploadPresigner
    def presign prefix, file_name
      ext_name = File.extname(file_name)
      file_name = "#{SecureRandom.uuid}#{ext_name}"
      upload_key = Pathname.new(prefix).join(file_name).to_s

      s3 = Aws::S3::Client.new(region: ENV["S3_REGION"],
        access_key_id: ENV["S3_KEY_ID"], secret_access_key: ENV["S3_SECRET_KEY"])
      signer = Aws::S3::Presigner.new(client: s3)
      url = signer.presigned_url(:put_object, bucket: ENV["S3_BUCKET"], key: upload_key)
      {
        presigned_url: url
      }
    end
  end
end
