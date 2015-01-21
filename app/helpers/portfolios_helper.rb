module PortfoliosHelper

  def update_button_text(portfolio)
    if portfolio.persisted?
      t('designer_center.portfolio.creation.update_button')
    else
      t('designer_center.portfolio.creation.create_button')
    end
  end

end


