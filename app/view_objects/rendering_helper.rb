class RenderingHelper < ActionView::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  def initialize
    super(Rails.root.join('app', 'views'))
  end

  def default_url_options
    Rails.configuration.action_mailer.default_url_options
  end
end
