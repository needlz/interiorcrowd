require 'rails_helper'

RSpec.describe SubscribeToNewsletterJob, type: :job do

  let(:client) { Fabricate(:client) }
  let(:user_role) { client.role }
  let(:user_id) { client.id }
  let(:job) { SubscribeToNewsletterJob.new }

  it 'subscribes a user to newsletter' do
    stub_gibbon_requests
    job.perform(user_role, user_id)
  end

end
