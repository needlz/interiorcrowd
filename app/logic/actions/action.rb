class Action

  def self.perform(*args)
    action = new(*args)
    action.perform
    action
  end

end
