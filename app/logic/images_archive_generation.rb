require 'zip'

class ImagesArchiveGeneration

  attr_reader :archive_path

  def initialize(contest, type)
    begin
      @images = ContestView.new(contest)
      @images = @images.send(type)
    rescue NoMethodError
      raise ArgumentError, 'Wrong image type'
    end
    @archive_path = ImagesArchiveGeneration.archive_path(contest, type)
  end

  def self.in_tmp_folder(path)
    "#{ tmp_dir }#{ path }"
  end

  def self.archive_path(contest, type)
    name = "contest_#{ contest.id }_#{ type }.zip"
    ImagesArchiveGeneration.in_tmp_folder(name)
  end

  def completed?
    archive_s3_object.exists?
  end

  def perform
    Dir.mkdir(ImagesArchiveGeneration.tmp_dir) unless File.exists?(ImagesArchiveGeneration.tmp_dir)
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
    @files = []
    images.each do |image|
      name = image.image_file_name
      path = ImagesArchiveGeneration.in_tmp_folder(name)

      image.image.copy_to_local_file(nil, path)
      @files << { name: name, path: path }
    end
    @files
  end

  def delete_temporary_file(path)
    FileUtils.rm(path)
  end

  def archive_s3_object
    s3 = AWS::S3.new
    bucket = s3.buckets[ENV['S3_BUCKET_NAME']]

    AWS::S3::S3Object.new(bucket, 'tmp/image_archives/' + File.basename(archive_path))
  end

  def self.tmp_dir
    "#{ Rails.root }/tmp/image_archives/"
  end

end
