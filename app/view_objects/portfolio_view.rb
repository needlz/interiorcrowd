class PortfolioView
  include ActionView::Helpers::FormOptionsHelper
  include Rails.application.routes.url_helpers

  delegate :years_of_expirience, :about, :personal_picture, :designer_id, :designer, to: :portfolio, allow_nil: true

  def initialize(portfolio)
    @portfolio = portfolio
  end

  def education_view
    items = [degree_name]
    items << I18n.t('designer_center.portfolio.creation.education.gifted') if portfolio.education_gifted
    items << I18n.t('designer_center.portfolio.creation.education.apprenticed') if portfolio.education_apprenticed
    items.join(', ').html_safe
  end

  def education_degree_select(prefix)
    degrees = Portfolio::DEGREES.map do |degree|
      [I18n.t("designer_center.portfolio.creation.education.degrees.#{ degree }"), degree]
    end
    select(prefix, 'degree', options_for_select(degrees, portfolio.degree), {}, { class: 'selectpicker form-selector' })
  end

  def expirience_level
    return unless portfolio.years_of_expirience
    if portfolio.years_of_expirience < 5
      I18n.t('designer_center.portfolio.show.expirience_levels.novice')
    elsif 5 <= portfolio.years_of_expirience && portfolio.years_of_expirience < 10
      I18n.t('designer_center.portfolio.show.expirience_levels.professional')
    elsif 10 <= portfolio.years_of_expirience
      I18n.t('designer_center.portfolio.show.expirience_levels.expirienced')
    end
  end

  def education_icon
    if portfolio.education_school
      portfolio.degree[0].capitalize
    else
      'S'
    end
  end

  def degree_name
    if portfolio.education_school
      degree = I18n.t("designer_center.portfolio.creation.education.degrees.#{ portfolio.degree }")
      I18n.t('designer_center.portfolio.show.degree_name', degree: degree)
    else
      I18n.t('designer_center.portfolio.show.self_educated')
    end
  end

  def personal_picture_url
    portfolio.try(:personal_picture) ? portfolio.personal_picture.image.url(:medium) : '/assets/portfolio_profile_image.png'
  end

  def designer_name
    portfolio.designer.name
  end

  def pictures_urls
    portfolio.pictures.map { |picture| picture.image.url }
  end

  def style_description
    return [] unless portfolio
    styles = Portfolio::STYLES.select { |style| portfolio.send("#{ style }_style") }
    result = styles.map { |style| I18n.t("designer_center.portfolio.creation.styles.#{ style }") }
    result << portfolio.style_description
    result.reject(&:blank?)
  end

  def style_description_texts
    style_description.join(', ')
  end

  def awards
    portfolio.portfolio_awards.map(&:name)
  end

  def show_invitation?(client)
    client && client.last_contest.designers_invitation_period?
  end

  def invited_by_client?(client)
    designer.invited_to_contest?(client.last_contest)
  end

  def exit_portfolio_path(client, designer)
    return client_center_index_path if client
    return designer_center_index_path if designer
    root_path
  end

  def owner?(owner)
    designer == owner
  end

  private

  attr_reader :portfolio
end
