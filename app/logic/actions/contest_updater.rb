class ContestUpdater

  def initialize(contest, contest_options)
    @contest = contest
    @contest_options = contest_options
  end

  def perform
    ActiveRecord::Base.transaction do
      contest.update_attributes!(contest_options.contest) if contest_options.contest
      update_options
    end
  end

  def update_options
    update_appeals(contest_options.appeals) if contest_options.appeals
    update_external_examples(contest_options.example_links) if contest_options.example_links
    update_space_images(contest_options.space_image_ids) if contest_options.space_image_ids
    update_example_images(contest_options.liked_example_ids) if contest_options.liked_example_ids
    update_preferred_retailers(contest_options.preferred_retailers) if contest_options.preferred_retailers.present?
    if contest.brief_pending? && contest.space_images.exists?
      submit_contest = SubmitContest.new(contest)
      submit_contest.perform
    end
  end

  private

  attr_reader :contest, :contest_options

  def update_appeals(options)
    Appeal.all.each do |appeal|
      contest_appeal = contest.contests_appeals.where(appeal_id: appeal.id).first_or_initialize
      if options[appeal.identifier]
        contest_appeal.assign_attributes(options[appeal.identifier])
        contest_appeal.save
      end
    end
  end

  def update_external_examples(urls)
    return unless urls
    contest.liked_external_examples.destroy_all
    urls.each do |url|
      contest.liked_external_examples << ImageLink.new(url: url)
    end
  end

  def update_space_images(image_ids)
    Image.update_contest(contest, image_ids, Image::SPACE)
  end

  def update_example_images(image_ids)
    Image.update_contest(contest, image_ids, Image::LIKED_EXAMPLE)
  end

  def update_preferred_retailers(preferred_retailers_params)
    contest.preferred_retailers.update_attributes!(preferred_retailers_params)
  end

end
