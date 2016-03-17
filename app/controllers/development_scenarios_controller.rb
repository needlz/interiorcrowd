class DevelopmentScenariosController < ApplicationController

  def perform
    scenario_class = params[:scenario_class].constantize
    method = params[:scenario_method]
    scenario = scenario_class.new(self, session)
    scenario.send(method)
  end

end
