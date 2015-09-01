class ErrorsLogger

  def self.log(exception, extra_data = nil)
    Rollbar.error(exception, extra_data)
  end

end
