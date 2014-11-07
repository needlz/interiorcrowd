module ContestsHelper

  def contest_creation_category_radiobutton(category)
    radio_button_tag "design_category",
                     category.id,
                     @creation_wizard.design_categories_checkboxes[category.id],
                     class: "design_element"
  end

  def areas_parent_dropdown(area)
    select_tag 'design_area',
               options_for_select(
                 @creation_wizard.available_design_areas.top_level.map { |area| [area.name, area.id]},
                 area.try(:id)
               )
  end

end
