class ContestAdditionalPreference

  PREFERENCES = {
    theme: [:have_consistent, :mix_styles],
    space: [:take_risk, :keep_simple],
    accessories: [:covering_open_space, :minimalistic],
    space_changes: [:seasonally, :keep_consistent],
    shop: [:antique_stores, :retailers]
  }

  attr_reader :name, :first_option, :second_option

  def self.preferences
    PREFERENCES.keys
  end

  def self.all(list = nil)
    selected_preferences = list || preferences
    selected_preferences.map { |preference| new(preference) }
  end

  def initialize(preference)
    @name = preference
    @first_option = PREFERENCES[preference][0]
    @second_option = PREFERENCES[preference][1]
  end

  def first_option_name
    I18n.t("contests.additional_details.#{ name }.#{ first_option }")
  end

  def second_option_name
    I18n.t("contests.additional_details.#{ name }.#{ second_option }")
  end

end
