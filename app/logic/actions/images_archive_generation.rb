require 'zip'

class ImagesArchiveGeneration

  ARCHIVES_BUCKET = 'tmp/image_archives'
  SERVER_TMP_FOLDER = 'tmp'
  IMAGES_ARCHIVES_LOCAL_FOLDER = "#{ SERVER_TMP_FOLDER }/image_archives"

  attr_reader :archive_path

  def initialize(images_source, type)
    begin
      @images = images_source.send(type)
    rescue NoMethodError
      raise ArgumentError, 'Wrong image type'
    end
    @archive_path = fetch_archive_path(images_source, type)
  end

  def completed?
    archive_s3_object.exists?
  end

  def perform
    prepare_tmp_folder
    generate_archive
    send_to_s3
    remove_temporary_files
  end

  def download_url
    archive_s3_object.url_for(:get, expires: 20.seconds, response_content_disposition: 'attachment;').to_s
  end

  private

  attr_reader :images

  def generate_archive
    Zip::File.open(archive_path, Zip::File::CREATE) do |zip|
      local_files.each do |file_attributes|
        filename = file_attributes[:name]
        filepath = file_attributes[:path]
        zip.add(filename, filepath)
      end
    end
  end

  def send_to_s3
    archive_s3_object.write(
        File.open(archive_path, 'rb')
    )
  end

  def remove_temporary_files
    local_files.each do |file_attributes|
      File.delete(file_attributes[:path])
    end
    File.delete(archive_path)
  end

  def local_files
    return @files if @files
    base_names = []
    @files = images.map do |image|
      unique_name_base = UniquePathGenerator.generate(File.basename(image.image_file_name, '.*'), base_names)
      unique_name = unique_name_base + File.extname(image.image_file_name)
      base_names << unique_name_base
      unique_path = in_tmp_folder(unique_name)
      image.image.copy_to_local_file(nil, unique_path)
      { name: unique_name, path: unique_path }
    end
  end

  def delete_temporary_file(path)
    FileUtils.rm(path)
  end

  def archive_s3_object
    s3 = AWS::S3.new
    bucket = s3.buckets[Settings.aws.bucket_name]

    AWS::S3::S3Object.new(bucket, "#{ ARCHIVES_BUCKET }/#{ File.basename(archive_path) }")
  end

  def tmp_dir
    "#{ Settings.root_folder }/#{ IMAGES_ARCHIVES_LOCAL_FOLDER }"
  end

  def fetch_archive_path(images_source, type)
    name = "#{ images_source.class.name }_#{ images_source.id }_#{ type }.zip"
    in_tmp_folder(name)
  end

  def in_tmp_folder(path)
    "#{ tmp_dir }/#{ path }"
  end

  def prepare_tmp_folder
    Dir.mkdir(tmp_dir) unless File.exists?(tmp_dir)
  end

end
