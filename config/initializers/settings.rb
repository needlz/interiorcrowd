class Settings

  def self.method_missing(method_sym, *arguments, &block)
    if Figaro.env.respond_to?(method_sym)
      Figaro.env.send(method_sym)
    else
      super
    end
  end

  def self.[](key)
    ENV[key]
  end

  def self.beta_notification_emails
    Figaro.env.beta_notification_emails.split(',')
  end

end
