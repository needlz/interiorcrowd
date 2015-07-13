module Navigation

  class DesignerCenter < Base
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
end
