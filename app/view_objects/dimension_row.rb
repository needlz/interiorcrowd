class DimensionRow

  DIMENSIONS = [
    { identifier: :length, mandatory: true },
    { identifier: :width, mandatory: true },
    { identifier: :height, mandatory: false }
  ]

  attr_reader :mandatory, :identifier, :value

  def initialize(identifier, mandatory)
    @identifier = identifier
    @mandatory = mandatory
  end

  def self.from(options)
    DIMENSIONS.map do |dimension|
      dimension_row = new(dimension[:identifier], dimension[:mandatory])
      if options
        dimension_row.value = options.kind_of?(Hash) ? options[dimension_row.identifier] : options.send("space_#{ dimension_row.identifier }")
      else
        dimension_row.value = nil
      end

      dimension_row
    end
  end

  def name
    I18n.t("contests.dimensions.#{ identifier }")
  end

  def to_inches
    return unless value
    value * 12
  end

  def to_feet
    value
  end

  def value=(value)
    @value = (value.to_i if value.present?)
  end

  def feet_identifier
    'f_' + (identifier.to_s)
  end

  def inches_identifier
    'i_' + (identifier.to_s)
  end

end