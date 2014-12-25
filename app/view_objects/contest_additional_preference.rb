class ContestAdditionalPreference

  PREFERENCES = {
    theme: [:have_consistent, :mix_styles],
    space: [:take_risk, :keep_simple],
    accessories: [:covering_open_space, :minimalistic],
    changes: [:seasonally, :keep_consistent],
    shop: [:antique_stores, :retailers]
  }

  attr_reader :name, :first_option, :second_option, :selected

  def self.from(contest)
    PREFERENCES.map do |preference, options|
      new({ preference: preference, first_option: options[0], second_option: options[1], selected: '' })
    end
  end

  def initialize(options)
    @name = options[:preference]
    @first_option = options[:first_option]
    @second_option = options[:second_option]
    @selected = options[:selected]
  end

  def first_option_name
    I18n.t("contests.additional_details.#{ name }.#{ first_option }")
  end

  def second_option_name
    I18n.t("contests.additional_details.#{ name }.#{ second_option }")
  end

end
