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

  def initialize(scale)
    @first, @second = scale[:first], scale[:second]
    @value = default_value
  end

  def self.from(options)
    SCALES.map do |scale|
      appeal = new(scale)
      appeal.value = options
      appeal
    end
  end

  def identifier
    "#{ first }_appeal_scale".to_sym
  end

  def first_name
    name(first)
  end

  def second_name
    name(second)
  end

  def value=(value)
    if value.present?
      @value = value.kind_of?(Hash) ? value[identifier].to_i : value.send(identifier).to_i
    else
      @value = default_value
    end
  end

  def second_value
    100 - value
  end

  private

  def default_value
    0
  end

  def name(key)
    I18n.t "contests.appleals.#{ key.to_s }"
  end

end
