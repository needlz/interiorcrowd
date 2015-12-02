RSpec.shared_examples 'validates email' do

  context 'when email is invalid' do
    let(:email) { 'email@example' }

    it 'does not save record' do
      expect { object.update_attributes!(email: email) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'when email is valid' do
    let(:email) { 'email@example.com' }

    it 'saves record' do
      object.update_attributes!(email: email)
      expect(object.email).to eq email
    end
  end

end
