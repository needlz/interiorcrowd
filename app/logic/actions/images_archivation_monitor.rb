class ImagesArchivationMonitor

  def self.request_archive(images_source, images_type)
    generation = ImagesArchiveGeneration.new(images_source, images_type)
    status = status(images_source, images_type, generation)
    return if status == :in_process
    return generation.download_url if status == :completed
    if status == :not_started
      Jobs::GeneratePhotosArchive.schedule(images_source, images_type)
      nil
    end
  end

  private

  def self.status(images_source, images_type, generation)
    return :in_process if enqueued?(images_source, images_type)
    return :completed if generation.completed?
    :not_started
  end

  def self.enqueued?(images_source, images_type)
    DelayedJob.where("#{ images_source.class.name.underscore }_id".to_sym => images_source.id, image_type: images_type).exists?
  end

end
