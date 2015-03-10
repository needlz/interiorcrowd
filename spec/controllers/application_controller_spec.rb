require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    include HomeHelper
  end

  describe '#need_help_path' do
    context 'not logged in' do
      it 'returns path to FAQ' do
        expect(subject.need_help_path).to eq(faq_path)
      end
    end

    context 'logged in as client' do
      before do
        sign_in(Fabricate(:client))
      end

      it 'returns path to client\'s part of FAQ' do
        expect(subject.need_help_path).to eq(faq_path(anchor: 'client'))
      end
    end

    context 'logged in as designer' do
      before do
        sign_in(Fabricate(:designer))
      end

      it 'returns path to designer\'s part of FAQ' do
        expect(subject.need_help_path).to eq(faq_path(anchor: 'designer'))
      end
    end

  end

end
