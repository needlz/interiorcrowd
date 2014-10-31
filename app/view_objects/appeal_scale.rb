class AppealScale

  SCALES = [
      { min: :feminine, max: :masculine },
      { min: :elegant, max: :eclectic },
      { min: :traditional, max: :modern },
      { min: :conservative, max: :bold },
      { min: :muted, max: :colorful },
      { min: :timeless, max: :trendy },
      { min: :fancy, max: :playful }
  ]

  attr_reader :value, :min, :max

  def initialize(identifier, value = 0)
    @min, @max = scale(identifier)
    @value = value
  end

  def self.from options
    options.map { |option| new option.key, option.value }
  end

  def identifier
    min
  end

  def min_name
    name(min)
  end

  def max_name
    name(max)
  end

  private

  def scale identifier
    result = SCALES.detect {|scale| scale[:min] == identifier }
    return result[:min], result[:max]
  end

  def name(key)
    t "contests.appleals.#{ key.to_s }"
  end

end

appeal_scale = AppealScale.new({min: :muted, max: :colorful}, 50)
appeal_scale = AppealScale.new(:muted, 20)

AppealScale.all do |identifier|
  session[identifier]

  contest["cd_#{identifier}_scale"]
end