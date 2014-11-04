class SpaceDimension

  DIMENSIONS = [
    { identifier: :length, mandatory: true },
    { identifier: :width, mandatory: true },
    { identifier: :height, mandatory: false }
  ]

  INCHES_IN_FEET = 12

  attr_reader :mandatory, :identifier, :value

  def initialize(identifier, mandatory)
    @identifier = identifier
    @mandatory = mandatory
  end

  def self.from(options)
    DIMENSIONS.map do |dimension|
      space_dimension = new(dimension[:identifier], dimension[:mandatory])
      space_dimension.value = options
      space_dimension
    end
  end

  def name
    I18n.t("contests.dimensions.#{ identifier }")
  end

  def to_inches
    return unless value
    value * INCHES_IN_FEET
  end

  def to_feet
    value
  end

  def value=(value)
    if value
      @value = value.kind_of?(Hash) ? value[identifier].to_i : value.send("space_#{ identifier }")
    else
      @value = nil
    end
  end

  def feet_identifier
    "#{identifier}_feet"
  end

  def inches_identifier
    "#{identifier}_inches"
  end

end