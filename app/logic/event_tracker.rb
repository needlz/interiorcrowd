class EventTracker

  attr_accessor :user

  def initialize
    @tracker = Mixpanel::Tracker.new(Settings.mixpanel_token) do |type, message|
      Jobs::MixpanelLogRecord.schedule(type, message)
    end
  end

  def login
    tracker.people.set(current_user_identifier, {
        'First name' => user.first_name,
        'Last name' => user.last_name,
        'Email' => user.email
    })
    tracker.people.increment(current_user_identifier, {
        'Logins' => 1,
    })
    tracker.track(current_user_identifier, login_event_name)
  end

  def current_user_identifier
    "#{ user.role } #{ user.id }" unless user.anonymous?
  end

  def contest_request_submitted(contest_request)
    tracker.track(current_user_identifier, 'Concept board submitted', { contest_request_id: contest_request.id })
  end

  def final_design_submitted(contest_request)
    tracker.track(current_user_identifier, 'Final design submitted', { contest_request_id: contest_request.id })
  end

  private

  attr_reader :tracker

  def login_event_name
    "#{ user.role.capitalize } logged in"
  end

end
