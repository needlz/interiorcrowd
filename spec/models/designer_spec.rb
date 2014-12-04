require "rails_helper"

RSpec.describe Designer do
  let(:designer) { Fabricate(:designer) }

  it 'know if it has portfolio finished' do
    designer.update_attributes(portfolio_published: true)
    expect(designer.has_portfolio?).to be_truthy
  end

  it 'know if it has portfolio unfinished' do
    expect(designer.has_portfolio?).to be_falsy
  end
end
