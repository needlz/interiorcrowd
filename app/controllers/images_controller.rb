class ImagesController < ApplicationController
    
  def sign
    render :json => {
      :policy => s3_upload_policy_document,
      :signature => s3_upload_signature,
      :key => "temporary/#{ params[:filename] }",
      content_type: params[:type]
    }
  end

  def on_uploaded
    s3 = AWS::S3.new
    filename = params[:filename]
    path = 'temporary/' + filename
    bucket_name = Settings.aws.bucket_name
    bucket = s3.buckets[bucket_name]
    direct_upload_head = bucket.objects[path].head

    image = Image.create!(
      image: StringIO.new('dummy'),
      uploader_role: current_user.role,
      uploader_id: current_user.try(:id),
      image_file_name: filename,
      image_file_size: direct_upload_head.content_length,
      image_content_type: direct_upload_head.content_type,
    )

    render json: { files: [ image.reload.thumbnail.merge(original_name: filename) ] }
  end

  def ready
    ids = params[:images_ids].split(',')
    images = Image.where(id: ids)
    result = images.map { |image| { image_id: image.id, processed: !image.image.processing?, file_type: image.file_type } }
    render json: result
  end

  def sign
    render :json => {
      :policy => s3_upload_policy_document,
      :signature => s3_upload_signature,
      :key => "temporary/#{ params[:filename] }",
      content_type: params[:type]
    }
  end

  def on_uploaded
    s3 = AWS::S3.new
    filename = params[:filename]
    path = 'temporary/' + filename
    bucket_name = Settings.aws.bucket_name
    bucket = s3.buckets[bucket_name]
    direct_upload_head = bucket.objects[path].head

    image = Image.new(
      image: StringIO.new('dummy'),
      uploader_role: current_user.role,
      uploader_id: current_user.try(:id),
      image_file_name: filename,
      image_file_size: direct_upload_head.content_length,
      image_content_type: direct_upload_head.content_type,
    )
    image.save!

    render json: { files: [ image.reload.thumbnail.merge(original_name: filename) ] }
  end

  private

  def file_details(file)
    file.thumbnail.merge(original_name: params[:image][:image].original_filename)
  end

  # generate the policy document that amazon is expecting.
  def s3_upload_policy_document
    return @policy if @policy
    ret = {"expiration" => 5.minutes.from_now.utc.xmlschema,
           "conditions" =>  [
             {"bucket" => Settings.aws.bucket_name},
             ["starts-with", "$key", 'temporary/'],
             {"acl" => "public-read"},
             {"success_action_status" => "200"},
             {'Content-Type' => params[:type] }
           ]
    }
    @policy = Base64.encode64(ret.to_json).gsub(/\n/,'')
  end

  # sign our request by Base64 encoding the policy document.
  def s3_upload_signature
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), Settings.aws.secret_access_key, s3_upload_policy_document)).gsub("\n","")
  end

end
