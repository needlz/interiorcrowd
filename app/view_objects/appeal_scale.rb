class AppealScale

  SCALES = [
    :vintage,
    :eclectic,
    :midcentury_modern,
    :rustic_elegance,
    :coastal,
    :traditional,
    :transitional,
    :modern,
    :hollywood_regency
  ]

  attr_reader :value, :description, :retailers
  attr_accessor :reason

  def initialize(appeal)
    @appeal = appeal
    @key = appeal.name
    @value = default_value
    @description = I18n.t("contests.appeals.#{ key.to_s }.description")
    @retailers = I18n.t("contests.appeals.#{ key.to_s }.retailers")
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

  def name
    localized_name(key)
  end

  def value=(value)
    if value.present?
      @value = value.to_i
    else
      @value = nil
    end
  end

  def second_value
    100 - value.to_i
  end

  def opinion
    AppealScale.localized_appeal_value(value_key)
  end

  def collage_picture
    "/assets/style_collages/Collage#{ appeal.id }.png"
  end

  def value_key
    ContestCreationWizard::APPEAL_FEEDBACK.each do |appeal|
      return appeal[:name] if appeal[:value] == value
    end
  end

  def self.localized_appeal_value(value)
    I18n.t("contests.appeal_values.#{ value }")
  end

  private

  attr_reader :appeal, :key

  def self.initialize_from_options(options)
    Appeal.all.order(:id).map do |appeal|
      appeal_scale = new(appeal)
      appeal_scale.value = options[appeal.identifier].try(:[], :value)
      appeal_scale.reason = options[appeal.identifier].try(:[], :reason)
      appeal_scale
    end
  end

  def self.initialize_from_appeals(contests_appeals)
    Appeal.all.order(:id).map do |appeal|
      appeal_scale = new(appeal)
      contest_appeal = contests_appeals.find_by_appeal_id(appeal.id)
      if contest_appeal
        appeal_scale.value = contest_appeal.value
        appeal_scale.reason = contest_appeal.reason
      end
      appeal_scale
    end
  end

  def default_value
    nil
  end

  def localized_name(key)
    I18n.t("contests.appeals.#{ key.to_s }.name")
  end

end
