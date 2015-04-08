module Jobs

  class GeneratePhotosArchive

    def self.schedule(contest, images_type, args = {})
      Delayed::Job.enqueue(new(contest.id, images_type), { contest_id: contest.id, image_type: images_type }.merge(args))
    end

    def self.request_archive(contest, images_type)
      generation = ImagesArchiveGeneration.new(contest, images_type)
      status = status(contest, images_type, generation)
      return if status == :in_process
      return generation.download_url if status == :completed
      if status == :not_started
        schedule(contest, images_type)
        nil
      end
    end

    def self.enqueued?(contest, images_type)
      DelayedJob.where(contest_id: contest.id, image_type: images_type).exists?
    end

    def initialize(contest_id, type)
      @contest = Contest.find(contest_id)
      @type = type
    end

    def perform
      generation = ImagesArchiveGeneration.new(contest, type)
      generation.perform
    end

    def queue_name
      Jobs::ARCHIVE_QUEUE
    end

    private

    attr_reader :contest, :type

    def self.status(contest, images_type, generation)
      if enqueued?(contest, images_type)
        :in_process
      else
        if generation.completed?
          :completed
        else
          :not_started
        end
      end
    end

  end

end
