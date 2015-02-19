class DesignCategoryView

  delegate :id, to: :design_category

  def initialize(design_category)
    @design_category = design_category
  end

  def name
    I18n.t("contests.titles.brief.packages.#{ design_category.name }.name")
  end

  def description
    I18n.t("contests.titles.brief.packages.#{ design_category.name }.description")
  end

  def quote
    I18n.t("contests.titles.brief.packages.#{ design_category.name }.quote")
  end

  def picture
    design_category.before_picture
  end

  attr_reader :design_category

end
