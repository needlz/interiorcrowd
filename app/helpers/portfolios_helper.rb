module PortfoliosHelper

  def update_button_text(portfolio)
    if portfolio.persisted?
      t('designer_center.portfolio.creation.update_button')
    else
      t('designer_center.portfolio.creation.create_button')
    end
  end

  def cover_image_options
    { style: ("background-image: #{ css_url(@portfolio_view.cover_picture_url) };" if @portfolio_view.cover_picture_url),
      data: {
        x: @portfolio_view.cover_x_percents_offset,
        y: @portfolio_view.cover_y_percents_offset
      }
    }
  end

end


