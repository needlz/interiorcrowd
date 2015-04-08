class ImagesArchivationMonitor

  def self.request_archive(contest, images_type)
    generation = ImagesArchiveGeneration.new(contest, images_type)
    status = status(contest, images_type, generation)
    return if status == :in_process
    return generation.download_url if status == :completed
    if status == :not_started
      Jobs::GeneratePhotosArchive.schedule(contest, images_type)
      nil
    end
  end

  private

  def self.status(contest, images_type, generation)
    return :in_process if enqueued?(contest, images_type)
    return :completed if generation.completed?
    :not_started
  end

  def self.enqueued?(contest, images_type)
    DelayedJob.where(contest_id: contest.id, image_type: images_type).exists?
  end


end
