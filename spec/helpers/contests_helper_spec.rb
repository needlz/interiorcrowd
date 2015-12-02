require 'rails_helper'

RSpec.describe ContestsHelper do
  describe '#force_link_protocol' do
    context 'empty string passed' do
      it 'returns nothing' do
        expect(force_link_protocol('')).to eq('')
      end
    end

    context 'only base url passed' do
      it 'adds protocol scheme' do
        expect(force_link_protocol('gmail.com')).to eq('http://gmail.com')
      end
    end

    context 'base url with scheme passed' do
      it "doesn't add protocol scheme" do
        expect(force_link_protocol('http://gmail.com')).to eq('http://gmail.com')
      end
    end
  end

  describe '#get_link_base_url' do
    it 'returns base url' do
      base_url = 'http://www.interiorcrowd.com'
      test_url = 'http://www.interiorcrowd.com/designer_center/responses/36?some_param=%27test%27&test_id=28'
      expect(get_link_base_url(test_url)).to eq(base_url)
    end
  end

end
