module Jobs

  class GeneratePhotosArchive

    def self.schedule(contest, images_type, args = {})
      worker = new(contest.id, images_type)
      job_attributes = { contest_id: contest.id, image_type: images_type }.merge(args)
      Delayed::Job.enqueue(worker, job_attributes)
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

  end

end
