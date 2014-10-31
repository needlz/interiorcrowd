module ContestsHelper

  def contest_creation_category_checkbox(category)
    check_box_tag "design_category[]",
                  category.id,
                  @creation_wizard.design_categories_checkboxes[category.id],
                  class: "design_element"
  end

  def area_checkbox(area, options)
    check_box_tag("design_space[]",
                  area.id,
                  @creation_wizard.design_areas_checkboxes[area.id],
                  options.merge( { class: "design_space" })
    )
  end

  def appeal_name(appeal)
    t("contests.appleals.#{ appeal.to_s }")
  end

end
