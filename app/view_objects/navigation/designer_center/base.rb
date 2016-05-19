class Navigation::DesignerCenter::Base < Navigation::Base
  def initialize(active_tab_or_options = nil, options = nil)
    if active_tab_or_options.kind_of? Hash
      options = active_tab_or_options
    else
      @active_tab = active_tab_or_options
    end
    if options
      @contest = options[:contest]
      @contest_request = options[:contest_request]
    end
  end

  def tabs
    {
      requests: { name: I18n.t('designer_center.navigation.respond'),
                    href: designer_center_response_index_path},
      contests: { name: I18n.t('designer_center.navigation.preview_contests'),
                    href: designer_center_contest_index_path},
      training: { name: I18n.t('designer_center.navigation.training'),
                  href: designer_center_training_path},
      portfolio: { name: I18n.t('designer_center.navigation.create_portfolio'),
                   href: edit_portfolio_path },
      updates: { name: I18n.t('designer_center.navigation.updates'),
                  href: designer_center_updates_path}
    }
  end
end
