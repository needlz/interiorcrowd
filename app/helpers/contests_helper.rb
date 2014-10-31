module ContestsHelper

  def contest_creation_category_checkbox(category)
    check_box_tag "design_cat[]",
                  category.id,
                  @creation_wizard.design_categories_checkboxes[category.id],
                  class: "design_element"
  end

  def contest_creation_category_checkbox_div_class(category)
    if category.image_name.present? && category.image_name != 'null'
      'col-sm-3'
    else
      'col-sm-5'
    end
  end

  def contest_creation_breadcrumb_class(step_index)
    if step_index < @creation_wizard.active_step_index
      'previous'
    elsif step_index == @creation_wizard.active_step_index
      'active'
    else
      'next'
    end
  end

  def area_checkbox(area, options)
    check_box_tag("design_space[]",
                  area.id,
                  @creation_wizard.design_areas_checkboxes[area.id],
                  options.merge( { class: "design_space" })
    )
  end

end
