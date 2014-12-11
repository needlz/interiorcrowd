module Navigation

  class DesignerCenter < Base
    def tabs
      [ { name: I18n.t('designer_center.navigation.create_portfolio'),
          routes: [{ controller: 'portfolios', action: 'edit' },
                   { controller: 'portfolios', action: 'new' }],
          href: view_context.edit_portfolio_path },
        { name: I18n.t('designer_center.navigation.preview_contests'),
          routes: [{ controller: 'designer_center_contests', action: 'index' },
                   { controller: 'designer_center_contests', action: 'show' }],
          href: view_context.designer_center_contest_index_path} ]
    end
  end
end
