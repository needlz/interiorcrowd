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
      if options
        appeal.value = options.kind_of?(Hash) ? options[appeal.identifier] : options.send("cd_#{ appeal.identifier }_scale")
      else
        appeal.value = 0
      end

      appeal
    end
  end

  def identifier
    first
  end

  def first_name
    name(first)
  end

  def second_name
    name(second)
  end

  def value=(value)
    @value = value.to_i || default_value
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