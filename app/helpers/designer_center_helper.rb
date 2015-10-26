module DesignerCenterHelper
  def format_comment(text)
    auto_link(simple_format(text), html: { target: '_blank' }).html_safe
  end
end
