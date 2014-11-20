module ContestsHelper

  def contest_creation_category_radiobutton(category)
    radio_button_tag "design_category",
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
    select_tag 'design_area',
               options_for_select(
                 [default_option] + areas.map { |area| [area.name, area.id]},
                 selected_area.try(:id)
               ),
               options
  end

  def plans
    [{ plan_id: 1, price: 99, designs_count: 2, money_back_guarantee: false },
     { plan_id: 2, price: 199, designs_count: 10, money_back_guarantee: false },
     { plan_id: 3, price: 299, designs_count: 15, money_back_guarantee: true }]
  end

end
