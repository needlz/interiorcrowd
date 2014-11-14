class AppealScale

  SCALES = [
      { first: :feminine, second: :masculine },
      { first: :elegant, second: :eclectic },
      { first: :traditional, second: :modern },
      { first: :conservative, second: :bold },
      { first: :muted, second: :colorful },
      { first: :timeless, second: :trendy },
      { first: :fancy, second: :playful }
  ]

  attr_reader :first, :second, :value
  attr_accessor :reason

  def initialize(appeal)
    @appeal = appeal
    @first, @second = appeal.first_name, appeal.second_name
    @value = default_value
  end

  def self.from(options)
    options ||= {}
    if options.kind_of?(Hash)
      initialize_from_options(options)
    else
      initialize_from_appeals(options)
    end
  end

  def identifier
    appeal.identifier
  end

  def first_name
    name(first)
  end

  def second_name
    name(second)
  end

  def value=(value)
    if value.present?
      @value = value
    else
      @value = default_value
    end
  end

  def second_value
    100 - value
  end

  private

  attr_reader :appeal

  def self.initialize_from_options(options)
    Appeal.all.order(:id).map do |appeal|
      appeal_scale = new(appeal)
      appeal_scale.value = options[appeal.identifier].try(:[], :value).to_i
      appeal_scale.reason = options[appeal.identifier].try(:[], :reason)
      appeal_scale
    end
  end

  def self.initialize_from_appeals(contests_appeals)
    contests_appeals.map do |contest_appeal|
      appeal_scale = new(contest_appeal.appeal)
      appeal_scale.value = contest_appeal.value
      appeal_scale.reason = contest_appeal.reason
      appeal_scale
    end
  end

  def default_value
    0
  end

  def name(key)
    I18n.t "contests.appleals.#{ key.to_s }"
  end

end
