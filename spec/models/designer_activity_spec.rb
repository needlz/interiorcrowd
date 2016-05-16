require 'rails_helper'

RSpec.describe DesignerActivity, type: :model do

  let(:designer_activity) { Fabricate(:designer_activity) }

  describe 'updating attributes' do
    context 'when due_date before start_date' do
      it 'creates error message' do
        expect(designer_activity.update_attributes(start_date: DateTime.now, due_date: DateTime.now - 3.days)).to equal(false)
      end
    end

    context 'when due_date after start_date' do
      it 'does not create error message' do
        designer_activity.update_attributes!(start_date: DateTime.now, due_date: DateTime.now + 3.days)
        expect(designer_activity.errors.messages[:due_date]).to_not be_present
      end
    end

    context 'when start_date and due_date not in range of one week' do
      it 'creates error message' do
        expect(designer_activity.update_attributes(start_date: DateTime.now, due_date: DateTime.now + 12.days)).to equal(false)
      end
    end

    context 'when start_date and due_date in range of one week' do
      it 'does not create error message' do
        designer_activity.update_attributes!(start_date: DateTime.now, due_date: DateTime.now + 3.days)
        expect(designer_activity.errors.messages[:due_date]).to_not be_present
      end
    end
  end

end
