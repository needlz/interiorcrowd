module Navigation

  class DesignerCenter < Base
    def tabs
      {
        portfolio: { name: I18n.t('designer_center.navigation.create_portfolio'),
          href: edit_portfolio_path },
        contests: { name: I18n.t('designer_center.navigation.preview_contests'),
          href: designer_center_contest_index_path},
        requests: { name: I18n.t('designer_center.navigation.respond'),
          href: designer_center_respond_index_path
        }
      }
    end
  end
end
