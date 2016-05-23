require 'rails_helper'

RSpec.describe DesignerActivityForm do
  let(:designer_activity) { Fabricate(:designer_activity) }

  it 'creates default designer activity when no parameters given' do
    form = DesignerActivityForm.new
    expect(form.tasks.count).to eq(1)
  end

  it 'adds given activity to tasks array' do
    designer_activity

    form = DesignerActivityForm.new(designer_activity)
    expect(form.tasks).to eq([designer_activity])
    expect(form.instance_variable_get(:@params)).to be_nil
  end

  it 'creates params when hash is given' do

    allow_any_instance_of(ActionController::Base).to receive(:params) {
      { designer_activity: {
          start_date: "05/19/2016",
          due_date: "05/23/2016"
        }
      }
    }
    form = DesignerActivityForm.new(designer_activity: { start_date: '', due_date: '' })
    expect(form.instance_variable_get(:@params)).to be_present
    expect(form.instance_variable_get(:@activity)).to be_nil
  end

end