require 'rails_helper'

RSpec.describe Jobs::CheckIfClientLeftIntakeForm do

  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }
  let(:job) { Jobs::CheckIfClientLeftIntakeForm.new(client.id) }

  def set_latest_contest_created_at
    client.update_attributes!(latest_contest_created_at: Time.current)
  end

  context 'client has left the site' do
    let(:client) { Fabricate(:client,
      last_activity_at: Time.now - Jobs::CheckIfClientLeftIntakeForm::INACTIVITY_PERIOD - 1.minute) }

    it 'sends an email' do
      job.perform
      expect(jobs_with_handler_like(Jobs::CheckIfClientLeftIntakeForm::MAILER_METHOD.to_s).count).to eq 1
    end

    context 'when a client has finished intake form' do
      before do
        set_latest_contest_created_at
      end

      it 'does not schedule next check' do
        job.perform
        expect(jobs_with_handler_like(Jobs::CheckIfClientLeftIntakeForm.name).count).to eq 0
      end
    end

    context 'when a client has not finished intake form' do
      it 'does not schedule next check' do
        job.perform
        expect(jobs_with_handler_like(Jobs::CheckIfClientLeftIntakeForm.name).count).to eq 0
      end
    end
  end

  context 'client present on site' do
    let(:client) { Fabricate(:client,
      last_activity_at: Time.now - Jobs::CheckIfClientLeftIntakeForm::INACTIVITY_PERIOD + 1.minute) }

    it 'does not send an email' do
      job.perform
      expect(jobs_with_handler_like(Jobs::CheckIfClientLeftIntakeForm::MAILER_METHOD.to_s).count).to eq 0
    end

    context 'when a client has finished intake form' do
      before do
        set_latest_contest_created_at
      end

      it 'does not schedule next check' do
        job.perform
        expect(jobs_with_handler_like(Jobs::CheckIfClientLeftIntakeForm.name).count).to eq 0
      end
    end

    context 'when a client has not finished intake form' do
      it 'schedules next check' do
        job.perform
        expect(jobs_with_handler_like(Jobs::CheckIfClientLeftIntakeForm.name).count).to eq 1
        expect(jobs_with_handler_like(Jobs::CheckIfClientLeftIntakeForm.name).first.run_at).to(
            be_within(2.seconds).of(Time.current + Jobs::CheckIfClientLeftIntakeForm::INACTIVITY_PERIOD / 2)
        )
      end
    end

  end

end
