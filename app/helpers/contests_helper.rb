module ContestsHelper

  def contest_creation_category_radiobutton(category)
    radio_button_tag 'design_brief[design_category]',
                     category.id,
                     @creation_wizard.design_categories_checkboxes[category.id],
                     class: "design_element regular-radio big-radio"
  end

end
