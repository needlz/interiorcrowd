module Navigation

  class DesignerCenter < Base
    def tabs
      {
        requests: { name: I18n.t('designer_center.navigation.respond'),
                      href: designer_center_response_index_path},
        contests: { name: I18n.t('designer_center.navigation.preview_contests'),
          href: designer_center_contest_index_path},
        training: { name: I18n.t('designer_center.navigation.training'),
                    href: training_designer_center_index_path},
        portfolio: { name: I18n.t('designer_center.navigation.create_portfolio'),
                     href: edit_portfolio_path },
        updates: { name: I18n.t('designer_center.navigation.updates'),
                    href: updates_designer_center_index_path}
      }
    end
  end
end
