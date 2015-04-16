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
    tracker.track(current_user_identifier, "#{ user.role.capitalize } login")
  end

  private

  attr_reader :tracker

  def current_user_identifier
    "#{ user.role } #{ user.id }" if user
  end

end
