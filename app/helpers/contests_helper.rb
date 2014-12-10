module ContestsHelper

  def contest_creation_category_radiobutton(category)
    radio_button_tag 'design_brief[design_category]',
                     category.id,
                     @creation_wizard.design_categories_checkboxes[category.id],
                     class: "design_element"
  end

  def areas_parent_dropdown(top_level_areas, selected_area)
    areas_dropdown(top_level_areas, selected_area.try(:parent) || selected_area)
  end

  def areas_child_dropdown(area, selected_area)
    return if area.children.blank?
    areas_dropdown(area.children,
                   selected_area,
                     class: 'area-children appeal',
                     data: { id: area.id },
                     style: 'display: none')
  end

  def areas_dropdown(areas, selected_area, options = {})
    default_option = [t('contests.default_selection'), '']
    select_tag 'design_brief[design_area]',
               options_for_select(
                 [default_option] + areas.map { |area| [area.name, area.id]},
                 selected_area.try(:id)
               ),
               options
  end

end
