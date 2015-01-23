require "rails_helper"

RSpec.describe DesignerInvitation do
  let(:designer) { Fabricate(:designer) }

  describe '#create' do
    it 'validates uniqueness of designer and contest id' do
      contest = Fabricate(:contest)
      Fabricate(:designer_invitation, designer: designer, contest: contest)
      expect(designer.designer_invitations.count).to eq 1
      expect { Fabricate(:designer_invitation, designer: designer, contest: contest) }.to raise_error
    end
  end

end
