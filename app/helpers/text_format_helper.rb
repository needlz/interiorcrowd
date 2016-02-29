module TextFormatHelper
  extend ActiveSupport::Concern

  include ActionView::Helpers::TextHelper
  included do
    extend ActionView::Helpers::SanitizeHelper::ClassMethods
  end

  def format_comment(text)
    auto_link(simple_format(text), html: { target: '_blank' }).html_safe
  end
end
