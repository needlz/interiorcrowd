class DesignerView

  delegate :first_name, :last_name, :name, :id, :invited_to_contest?, to: :designer
  delegate :personal_picture, :style_description_texts, :about, to: :portfolio_view, allow_nil: true

  def initialize(designer)
    @designer = designer
    @portfolio_view = PortfolioView.new(designer.portfolio)
  end

  def portfolio_path
    designer.try(:portfolio).try(:path)
  end

  def personal_picture_url
    portfolio_view.personal_picture_url
  end

  private

  attr_reader :designer, :portfolio_view

end
