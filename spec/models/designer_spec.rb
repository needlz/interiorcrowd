require "rails_helper"

RSpec.describe Designer do
  let(:designer) { Fabricate(:designer) }

  it 'knows if it has portfolio finished' do
    designer.update_attributes(portfolio_published: true)
    expect(designer.has_portfolio?).to be_truthy
  end

  it 'knows if it has portfolio unfinished' do
    expect(designer.has_portfolio?).to be_falsy
  end

  it 'has unique portfolio_path' do
    portfolio_path = 'portfolio_path'
    designer_with_different_path = Fabricate(:designer, portfolio_path: portfolio_path, email: 'a')
    designer.update_attributes(portfolio_path: portfolio_path)
    expect(designer.reload.portfolio_path).to_not eq portfolio_path
  end
end
