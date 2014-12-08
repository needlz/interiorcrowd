module PortfoliosHelper

  def portfolio_attributes
    ['path',
     'years_of_expirience',
     'education',
     'awards',
     'portfolio_pictures',
     'personal_picture',
     'style_description',
     'about']
  end

  def education_view(portfolio)
    items = [degree_name(portfolio)]
    items << t('designer_center.portfolio.creation.education.gifted') if portfolio.education_gifted
    items << t('designer_center.portfolio.creation.education.apprenticed') if portfolio.education_apprenticed
    items.join(', ').html_safe
  end

  def education_degree_select(prefix, portfolio)
    degrees = Portfolio::DEGREES.map do |key, value|
      [t("designer_center.portfolio.creation.education.degrees.#{ value }"), value]
    end
    select(prefix, 'degree', options_for_select(degrees, portfolio.degree))
  end

  def expirience_level(portfolio)
    if portfolio.years_of_expirience < 5
      t('designer_center.portfolio.show.expirience_levels.novice')
    elsif 5 <= portfolio.years_of_expirience && portfolio.years_of_expirience < 10
      t('designer_center.portfolio.show.expirience_levels.professional')
    elsif 10 <= portfolio.years_of_expirience
      t('designer_center.portfolio.show.expirience_levels.expirienced')
    end
  end

  def education_icon(portfolio)
    case portfolio.degree
      when Portfolio::DEGREES[:ASSOCIATES]
        'A'
      when Portfolio::DEGREES[:BACHELORS]
        'B'
      when Portfolio::DEGREES[:MASTERS]
        'M'
      when Portfolio::DEGREES[:DOCTORATE]
        'D'
      else
        'S'
    end
  end

  def degree_name(portfolio)
    if portfolio.education_school
      degree = t("designer_center.portfolio.creation.education.degrees.#{ portfolio.degree }")
      t('designer_center.portfolio.show.degree_name', degree: degree)
    else
      t('designer_center.portfolio.show.self_educated')
    end
  end
end
