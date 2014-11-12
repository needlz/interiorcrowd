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

  def initialize(appeal)
    @appeal = appeal
    @first, @second = appeal.first_name, appeal.second_name
    @value = default_value
  end

  def self.from(options)
    Appeal.all.order(:id).map do |appeal|
      appeal_scale = new(appeal)
      appeal_scale.value = options
      appeal_scale
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
      @value = value.kind_of?(Hash) ? value[identifier][:value].to_i : value.contests_appeals.find_by_appeal_id(appeal.id).value
    else
      @value = default_value
    end
  end

  def second_value
    100 - value
  end

  private

  attr_reader :appeal

  def default_value
    0
  end

  def name(key)
    I18n.t "contests.appleals.#{ key.to_s }"
  end

end
