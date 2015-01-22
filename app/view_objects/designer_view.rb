class DesignerView

  delegate :first_name, :last_name, :name, to: :designer
  delegate :personal_picture, :style_description, :about, to: :portfolio_view, allow_nil: true

  def initialize(designer)
    @designer = designer
    @portfolio_view = PortfolioView.new(designer.portfolio)
  end

  private

  attr_reader :designer, :portfolio_view

end
