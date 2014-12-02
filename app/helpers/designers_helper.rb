module DesignersHelper

  def sign_up_interior_design_title
    interior_design = t('designer_center.sign_up.interior_design')
    t('designer_center.sign_up.do_you_love', interior_design: content_tag(:strong, interior_design)).html_safe
  end

  def sign_up_style_title
    style = t('designer_center.sign_up.style')
    t('designer_center.sign_up.a_knock_for_style', style: content_tag(:strong, style)).html_safe
  end

end
